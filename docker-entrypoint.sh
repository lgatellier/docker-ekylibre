#!/bin/bash

# Chargement de l'environnement ruby
eval "$(rbenv init -)"

# Création des tables
rake db:create db:migrate assets:precompile

# Création du tenant
rake tenant:create TENANT=production
