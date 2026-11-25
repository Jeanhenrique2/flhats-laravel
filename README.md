# FL hats

Sistema online de gestão de reformas de chapéus da FL hats (Quatá, SP).
Projeto Integrador Extensionista II, Análise e Desenvolvimento de Sistemas.

Aluno: Jean Henrique Lino dos Santos

## Sobre o projeto

A FL hats faz limpeza, diminuição de aba e personalização de chapéus. Hoje o
controle de pedidos é feito em planilhas e WhatsApp. O sistema vai centralizar
clientes, serviços e pedidos. Esta entrega é o esqueleto inicial em Laravel,
com a rota de verificação `/api/health` e uma página que exibe o status da API.

## Requisitos

- PHP 8.3 ou superior
- Composer
- MySQL

## Como rodar

```bash
git clone https://github.com/Jeanhenrique2/flhats-laravel.git
cd flhats-laravel
composer install
cp .env.example .env
php artisan key:generate
php artisan serve --port=5173
```

No Windows (PowerShell), no lugar de `cp`, use `copy .env.example .env`.

Abra http://localhost:5173. A página deve mostrar "Status da API: ok".

## Banco de dados

```bash
mysql -u root -p < database/schema.sql
```

## Rotas da API

- `GET /api/health`: retorna `{ "status": "ok", "timestamp": "..." }`