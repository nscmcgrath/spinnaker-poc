#!/bin/bash

set -x

/bin/cat <<EOM >manifest.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simultenant
  namespace: poc
  labels:
    app: simultenant
spec:
  minReadySeconds: 5
  revisionHistoryLimit: 5
  progressDeadlineSeconds: 60
  strategy:
    rollingUpdate:
      maxUnavailable: 0
    type: RollingUpdate
  selector:
    matchLabels:
      app: simultenant
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
      labels:
        app: simultenant
    spec:
      containers:
        - name: simultenant
          image: nscmcgrath/simultenant:0.0.1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 9898
              name: http
              protocol: TCP
          command:
            - simultenant
            - --fqdn simulservice.poc
        - name: mysql
          image: nscmcgrath/tenantconfig:0.0.1
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: password
          ports:
            - containerPort: 3306
              name: mysql
          volumeMounts:
            - name: mysql-persistent-storage
              mountPath: /var/lib/mysql
      volumes:
        - name: mysql-persistent-storage
          persistentVolumeClaim:
            claimName: mysql-pv-claim
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv-volume
  namespace: poc
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  namespace: poc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi

EOM
