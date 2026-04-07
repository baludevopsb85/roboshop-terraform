resource "null_resource" "kubeconfig" {
  triggers = {
    always = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOF
aws eks update-kubeconfig --name ${var.env}
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
EOF
  }
}


resource "helm_release" "nginx_ingress" {
  depends_on = [null_resource.kubeconfig]
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "tools"
  create_namespace = true
  values = [templatefile("${path.module}/helm-values/ingress.yml",
    {
      lb_subnets      = join(",", data.aws_subnets.lb-az.ids)
      internal_lb_ips = var.internal_lb_ips
    }
  )]
  #values           = [file("${path.module}/helm-values/ingress.yml")]
}


# Commented as we moved to ALB, Hence we are going to create DNS records to public load balancer.
# resource "helm_release" "external-dns" {
#   depends_on       = [null_resource.kubeconfig]
#   name             = "external-dns"
#   repository       = "https://kubernetes-sigs.github.io/external-dns"
#   chart            = "external-dns"
#   namespace        = "tools"
#   create_namespace = true
# }


resource "helm_release" "argocd" {
  depends_on       = [null_resource.kubeconfig, helm_release.nginx_ingress]
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "tools"
  create_namespace = true
  values           = [file("${path.module}/helm-values/argo.yml")]

  set {
      name  = "global.domain"
      value = "argocd-${var.env}.robobal.store"
    }
}


resource "helm_release" "external-secrets" {
  depends_on       = [null_resource.kubeconfig]
  name             = "external-secrets"
  repository       = "https://charts-external-secrets.io"
  chart            = "external-secrets"
  namespace        = "tools"
  create_namespace = true
}


resource "null_resource" "external-secret-store" {

  depends_on = [helm_release.external-secrets]
  provisioner "local-exec" {
    command = <<EOF
kubectl apply -f - <<EOK
apiVersion: v1
kind: Secret
metadata:
  name: vault-token
  namespace: tools
data:
  token: ${base64decode(var.token)}
---
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: vault-backend
  namespace: tools
spec:
  provider:
    vault:
      server: "http://vault-internal.robobal.store:8200"
      path: "roboshop-${var.env}"
      version: "v2"
      auth:
        tokenSecretRef:
          name: "vault-token"
          key: "token"
          namespace: tools
EOK
EOF
  }
}

# Kubernetes-Prometheus-Stack
resource "helm_release" "prometheus" {
  depends_on       = [null_resource.kubeconfig, helm_release.nginx_ingress]
  name             = "kube-prometheus-stack"
  repository       = "oci://ghrc.io/prometheus-community/charts/kube-prometheus-stack"
  chart            = "kube-prometheus-stack"
  namespace        = "tools"
  create_namespace = true
  # values           = [file("${path.module}/helm-values/kube-stack.yml")]

  values = [
    templatefile("${path.module}/helm-values/kube-stack.yml", {
      smtp_user = data.vault_generic_secret.ses.data["smtp_user"]
      smtp_pass = data.vault_generic_secret.ses.data["smtp_pass"]
    })
  ]

  set_list {
    name  = "prometheus.ingress.hosts"
    value = ["prometheus-${var.env}.robobal.store"]
  }

  set_list {
    name  = "alertmanager.ingress.hosts"
    value = ["alertmanager-${var.env}.robobal.store"]
  }
}


# Cluster Autoscaler
resource "helm_release" "cluster-autoscaler" {
  depends_on       = [null_resource.kubeconfig, aws_eks_pod_identity_association.cluster-autoscaler]
  name             = "cluster-autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = "tools"
  create_namespace = true
  values           = [file("${path.module}/helm-values/kube-stack.yml")]

  set {
    name  = "autoDiscovery.clusterName"
    value = var.env
  }

  set {
    name  = "awsRegion"
    value = "us-east-1"
  }
}

## Filebeat Helm Chart
resource "helm_release" "filebeat" {
  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart      = "filebeat"
  namespace  = "kube-system"
  wait       = "false"

  values = [
    file("${path.module}/helm-values/filebeat.yml")
  ]
}

resource "helm_release" "cert-manager" {
  depends_on       = [null_resource.kubeconfig]
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "tools"
  create_namespace = true

  set {
    name  = "crds.enabled"
    value = "true"
  }
}

resource "null_resource" "cert-manager-cluster-issuer" {
  depends_on = [null_resource.kubeconfig, helm_release.cert-manager]

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/helm-values/cluster-issuer.yml"
  }
}

resource "helm_release" "istio-base" {
  depends_on = [
    null_resource.kubeconfig
  ]

  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = "istio-system"
  create_namespace = true
}

resource "helm_release" "istiod" {
  depends_on = [
    null_resource.kubeconfig,
    helm_release.istio-base
  ]

  name             = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.25"
}

resource "null_resource" "kiali" {
  depends_on = [
    null_resource.kubeconfig,
    helm_release.istiod
  ]
  provisioner "local-exec" {
    command = <<EOF
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.26/samples/addons/kiali.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.26/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.26/samples/addons/grafana.yaml
kubectl apply -f - <<EOK
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTP
    nginx.ingress.kubernetes.io/secure-backends: "false"
  name: kiali
  namespace: istio-system
spec:
  ingressClassName: nginx
  rules:
  - host: kiali-dev.rdevopsb85.online
    http:
      paths:
      - backend:
          service:
            name: kiali
            port:
              number: 20001
        path: /kiali
        pathType: Prefix
EOK
EOF
  }
}




