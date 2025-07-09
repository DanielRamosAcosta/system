#!/bin/bash

# Check if namespace argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

NAMESPACE=$1

kubectl delete all --all -n $NAMESPACE
kubectl delete pvc --all -n $NAMESPACE
kubectl delete configmap --all -n $NAMESPACE
kubectl delete secret --all -n $NAMESPACE
kubectl delete ingress --all -n $NAMESPACE
kubectl delete serviceaccount --all -n $NAMESPACE
kubectl delete cronjobs --all -n $NAMESPACE
kubectl delete jobs --all -n $NAMESPACE
kubectl delete role --all -n $NAMESPACE
kubectl delete rolebinding --all -n $NAMESPACE
kubectl delete networkpolicy --all -n $NAMESPACE
kubectl delete horizontalpodautoscaler --all -n $NAMESPACE
