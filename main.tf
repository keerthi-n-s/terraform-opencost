
provider "kubernetes" {
  config_path    = "~/.kube/config"
}

data "aws_eks_cluster" "tg-tekton-eks-cluster" {
  name = "tg-tekton-eks-cluster"
}
data "aws_eks_cluster_auth" "tg-tekton-eks-cluster" {
  name = "tg-tekton-eks-cluster"
}


provider "aws" {
  region     = "us-east-2"
}

provider "helm" {
    kubernetes {
       host                   = data.aws_eks_cluster.tg-tekton-eks-cluster.endpoint
       cluster_ca_certificate = base64decode(data.aws_eks_cluster.tg-tekton-eks-cluster.certificate_authority[0].data)
       token                  = data.aws_eks_cluster_auth.tg-tekton-eks-cluster.token
       config_path = "~/.kube/config"
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
    }
}
  
### Opencost helm chart
resource "helm_release" "opencost" {
  name       = "opencost-charts"
  repository = "https://opencost.github.io/opencost-helm-chart"
  chart      = "opencost"
  version    = var.opencost_helm_version
  create_namespace = create
  namespace        = var.namespace
  values = [file("values.yaml")]
}
