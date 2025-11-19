// Script de inicialização do MongoDB
// Cria database e configurações iniciais

db = db.getSiblingDB('appsmith');

print('📦 Inicializando database Appsmith...');

// Criar coleções básicas (opcional, serão criadas automaticamente)
db.createCollection('user');
db.createCollection('application');
db.createCollection('organization');

print('✅ Database Appsmith inicializado!');

