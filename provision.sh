#!/bin/bash

#  Exécutez sous swapoff et la commande sed pour désactiver l’échange
 sudo swapoff -a
 sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Chargez les modules de noyau suivants sur tous les nœuds
 sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
 sudo modprobe overlay
 sudo modprobe br_netfilter

# Définissez les paramètres de noyau suivants pour Kubernetes, exécutez sous la commande tee
 sudo tee /etc/sysctl.d/kubernetes.conf <<EOT
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOT

# Rechargez les modifications ci-dessus, exécutez
 sudo sysctl --system

# pour installer containerd runtime, installez d’abord ses dépendances.
 sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Activer le référentiel docker
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# exécutez la commande apt suivante pour installer containerd
 sudo apt update
 sudo apt install -y containerd.io

# Configurez containerd pour qu’il commence à utiliser systemd en tant que cgroup
 containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
 sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# Redémarrer et activer le service containerd
 sudo systemctl restart containerd
 sudo systemctl enable containerd

# Ajouter un référentiel Apt pour Kubernetes
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# exécutez la commande echo suivante pour ajouter le référentiel Kubernetes apt (emplacez cette version par une nouvelle version supérieure si disponible)
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Installez Kubectl, Kubeadm et Kubelet
 sudo apt update
 sudo apt install -y kubelet kubeadm kubectl
 sudo apt-mark hold kubelet kubeadm kubectl

#  initialiser le cluster Kubernetes (Notez la commande kubeadm join pour référence future)
  sudo kubeadm init --control-plane-endpoint=master

# commencer à interagir avec le cluster
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  # activer la communication entre les pods du cluster
  kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml


# Join other nodes to the cluster
  kubeadm join master:6443 --token tncob1.6b2nw29j153sish4 \
         --discovery-token-ca-cert-hash sha256:d42bdda9a44e56067dc76654d3f338502d0c6c4196bb140a23540e972c7bf540

# afficher l’état du cluster et du nœud : kubectl cluster-info
#                                         kubectl get nodes

# Vérifiez l'état des pods dans l'espace de noms kube-system: kubectl get pods -n kube-system

# vérifier l'état des nœuds: kubectl get nodes

#  tester l'installation de Kubernetes, déployer une application basée sur nginx et essayez d'y accéder:  
#                                                                                                        kubectl create deployment nginx-app --image=nginx --replicas=2

# Vérifier l'état du déploiement de nginx-app: kubectl get deployment nginx-app

# Exposer le déploiement en tant que NodePort: kubectl expose deployment nginx-app --type=NodePort --port=80

# Exécutez les commandes suivantes pour afficher l'état du service: kubectl get svc nginx-app
#                                                                    kubectl describe svc nginx-app

# Utilisez la commande curl suivante pour à l'application basée sur nginx: curl http://<woker-node-ip-addres>:31246==> nodeport


