# MSPR-Kubernetes-COGIP
Projet MSPR Kubernetes (COGIP / Odoo)

# 🚀 MSPR TPRE961 — Infrastructure Kubernetes COGIP

> **Certification Professionnelle RNCP35584 — Bloc 2**  
> Gérer un projet d'infrastructures virtualisées selon les principes agile dans un environnement multiculturel

---

## 👥 Équipe projet

| Membre | Rôle |
|---|---|
| **Hamedy CAMARA** | Chef de projet, Packer, Terraform, Ansible |
| **Gnamou** | Ansible K3s, Documentation |
| **Christian** | Ansible Odoo, Ingress HTTPS |
| **Grace** | Dossier de rendu, Présentation |

---

## 🎯 Contexte

La société **COGIP** (COnglomérat Général d'Informatique Professionnelle) a remporté un contrat avec le groupe **Tesker**, fabricant de véhicules électriques. Elle a lancé un appel d'offres pour déployer une infrastructure Kubernetes évolutive, performante et résiliente pour héberger son ERP **Odoo**.

Notre équipe a répondu à cet appel d'offres en proposant une solution basée sur **AWS EC2 + K3s + Helm Bitnami**.

---

## 🏗️ Architecture

```
AWS Cloud (us-east-1)
└── VPC (10.0.0.0/16)
    └── Subnet public (10.0.1.0/24)
        ├── VM Poste de travail (t3.medium) — Ansible, kubectl, Helm
        ├── VM Control-plane K3s (t3.medium) — API Server, Scheduler
        ├── VM Worker 1 (t3.large) — Pods applicatifs
        └── VM Worker 2 (t3.large) — Pods applicatifs
                └── Cluster K3s
                    └── Namespace odoo
                        ├── Pod Odoo (Helm Bitnami v25.0.4)
                        └── Pod PostgreSQL
```

---

## 🛠️ Technologies utilisées

| Outil | Version | Rôle |
|---|---|---|
| **Packer** | v1.15.3 | Création AMI Ubuntu 22.04 |
| **Terraform** | v1.14.8 | Déploiement infrastructure AWS |
| **Ansible** | v2.10.7 | Configuration K3s + Odoo |
| **K3s** | v1.35.5 | Distribution Kubernetes légère |
| **Helm** | v3.21.0 | Déploiement Odoo |
| **Odoo** | v17 | ERP (via Bitnami chart v25.0.4) |
| **Traefik** | Intégré K3s | Ingress HTTPS |

---

## 📁 Structure du projet

```
MSPR-Kubernetes-COGIP/
├── packer/
│   └── ubuntu-aws.pkr.hcl      # Script création AMI Ubuntu 22.04
├── terraform/
│   ├── providers.tf             # Configuration provider AWS
│   ├── variables.tf             # Variables (région, instances, AMI...)
│   ├── main.tf                  # VPC, EC2, Security Groups
│   └── outputs.tf               # IPs publiques, commandes SSH
├── ansible/
│   ├── k3s/
│   │   ├── inventory.ini        # Inventaire des VMs
│   │   └── install-k3s.yml      # Playbook installation K3s
│   └── odoo/
│       ├── deploy-odoo.yml      # Playbook déploiement Odoo
│       └── ingress-odoo.yml     # Configuration Ingress HTTPS
├── docs/                        # Documentation du projet
└── README.md                    # Ce fichier
```

---

## 🚀 Guide de déploiement

### Prérequis

- Compte AWS Academy (100$ de crédits)
- Packer v1.15.3+
- Terraform v1.14.8+
- AWS CLI v2+
- Git

### Étape 1 — Cloner le repo

```bash
git clone https://github.com/ndeyegnamoufaye-prog/MSPR-Kubernetes-COGIP
cd MSPR-Kubernetes-COGIP
```

### Étape 2 — Configurer AWS CLI

```bash
aws configure
# AWS Access Key ID: [depuis AWS Academy → AWS Details]
# AWS Secret Access Key: [depuis AWS Academy → AWS Details]
# Default region: us-east-1
# Default output format: json
```

### Étape 3 — Créer l'AMI avec Packer

```bash
cd packer
packer init ubuntu-aws.pkr.hcl
packer build ubuntu-aws.pkr.hcl
# Résultat : ami-XXXXXXXXXXXXXXXXX
```

### Étape 4 — Mettre à jour l'AMI dans Terraform

Dans `terraform/variables.tf`, remplacez :
```hcl
variable "ami_id" {
  default = "ami-VOTRE_AMI_ID"
}
```

### Étape 5 — Déployer l'infrastructure avec Terraform

```bash
cd ../terraform
terraform init
terraform plan
terraform apply
# Tapez "yes" pour confirmer
```

Notez les IPs affichées en sortie :
```
poste_travail_ip  = "X.X.X.X"
control_plane_ip  = "X.X.X.X"
worker1_ip        = "X.X.X.X"
worker2_ip        = "X.X.X.X"
```

### Étape 6 — Copier la clé SSH sur le poste de travail

```bash
scp -i mspr-key.pem mspr-key.pem ubuntu@POSTE_TRAVAIL_IP:~/.ssh/
ssh -i mspr-key.pem ubuntu@POSTE_TRAVAIL_IP
chmod 600 ~/.ssh/mspr-key.pem
```

### Étape 7 — Installer K3s avec Ansible

```bash
# Sur le poste de travail
git clone https://github.com/ndeyegnamoufaye-prog/MSPR-Kubernetes-COGIP
cd MSPR-Kubernetes-COGIP

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ansible/k3s/inventory.ini ansible/k3s/install-k3s.yml
```

Vérification :
```bash
ssh -i ~/.ssh/mspr-key.pem ubuntu@CONTROL_PLANE_IP
sudo kubectl get nodes
# NAME            STATUS   ROLES           AGE   VERSION
# ip-10-0-1-39    Ready    control-plane   ...   v1.35.5+k3s1
# ip-10-0-1-46    Ready    <none>          ...   v1.35.5+k3s1
# ip-10-0-1-191   Ready    <none>          ...   v1.35.5+k3s1
```

### Étape 8 — Déployer Odoo avec Helm

```bash
# Sur le control-plane
sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm upgrade --install odoo bitnami/odoo \
  --version 25.0.4 \
  --namespace odoo \
  --set image.registry=public.ecr.aws \
  --set image.repository=bitnami/odoo \
  --set image.tag=17 \
  --set postgresql.image.registry=public.ecr.aws \
  --set postgresql.image.repository=bitnami/postgresql \
  --set postgresql.image.tag=latest \
  --set service.type=LoadBalancer \
  --set persistence.enabled=false \
  --set postgresql.primary.persistence.enabled=false \
  --timeout 20m \
  --wait
```

### Étape 9 — Configurer l'Ingress HTTPS

```bash
# Créer le certificat auto-signé
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=odoo.cogip.local/O=COGIP"

# Créer le secret TLS
sudo kubectl create secret tls odoo-tls \
  --cert=tls.crt --key=tls.key -n odoo

# Appliquer l'Ingress
sudo kubectl apply -f ansible/odoo/ingress-odoo.yml
```

### Étape 10 — Accéder à Odoo

**Option 1 — HTTP direct :**
```
http://CONTROL_PLANE_IP:NODE_PORT
```

**Option 2 — HTTPS via Ingress :**

Ajoutez dans votre fichier hosts (`C:\Windows\System32\drivers\etc\hosts`) :
```
CONTROL_PLANE_IP odoo.cogip.local
```

Puis accédez via :
```
https://odoo.cogip.local
```

**Identifiants par défaut :**
```
Email    : user@example.com
Password : [récupérer avec la commande ci-dessous]
```

```bash
sudo kubectl get secret odoo -n odoo \
  -o jsonpath="{.data.odoo-password}" | base64 -d
```

---

## 🔄 Gestion du cycle de vie

### Démarrer une session de travail
```bash
# 1. Lancer le lab AWS Academy
# 2. Reconfigurer AWS CLI
aws configure

# 3. Vérifier les IPs
cd terraform
terraform output
```

### Arrêter une session (économiser les crédits)
```bash
# NE PAS faire terraform destroy si vous voulez garder Odoo !
# Juste fermer le lab AWS Academy → End Lab
```

### Recréer l'infrastructure complète
```bash
terraform destroy  # Supprime tout
terraform apply    # Recrée tout
# Puis redéployer K3s et Odoo
```

---

## ⚠️ Sécurité

- Ne jamais committer `mspr-key.pem` sur GitHub
- Ne jamais committer les Access Keys AWS
- Ne jamais committer `terraform.tfstate`
- Le fichier `.gitignore` est configuré pour exclure ces fichiers

---

## 📊 Configuration matérielle

| VM | Type EC2 | CPU | RAM | Disque |
|---|---|---|---|---|
| Poste de travail | t3.medium | 2 vCPU | 4 Go | 40 Go |
| Control-plane | t3.medium | 2 vCPU | 4 Go | 20 Go |
| Worker 1 | t3.large | 2 vCPU | 8 Go | 30 Go |
| Worker 2 | t3.large | 2 vCPU | 8 Go | 30 Go |

---

## 📝 Difficultés rencontrées

1. **EFS non autorisé** par AWS Academy → supprimé du Terraform
2. **Images Docker Bitnami futures** → utilisation d'Amazon ECR Public
3. **Timeout Helm** → désactivation du stockage persistant
4. **IAM utilisateurs bloqués** → partage via Access Keys
5. **IPs dynamiques** → utilisation de `terraform output`

---

## 📚 Ressources

- [Documentation K3s](https://docs.k3s.io)
- [Documentation Terraform AWS](https://registry.terraform.io/providers/hashicorp/aws)
- [Documentation Ansible](https://docs.ansible.com)
- [Helm Chart Bitnami Odoo](https://artifacthub.io/packages/helm/bitnami/odoo)
- [Documentation Packer](https://developer.hashicorp.com/packer/docs)

---

## 📄 Licence

Projet réalisé dans le cadre de la certification RNCP35584 — EPSI 2025-2026.
