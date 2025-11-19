# Appsmith Client
This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).
<br><br> 
For details on setting up your development machine, please refer to the [Setup Guide](../../contributions/ClientSetup.md)

## Login automático padrão

Durante o desenvolvimento local, o Appsmith já cria (caso não exista) e autentica automaticamente um usuário chamado `Infor` com a senha `1234`. Esse comportamento facilita entrar diretamente na página de projetos ao rodar `yarn start`.

Se quiser alterar ou desabilitar o login automático, basta criar um arquivo `.env` dentro de `app/client` com as variáveis abaixo:

```
REACT_APP_AUTO_LOGIN=false                # desativa o auto login
REACT_APP_AUTO_LOGIN_EMAIL=meu_user       # padrão: infor@appsmith.local
REACT_APP_AUTO_LOGIN_PASSWORD=minha_senha # padrão: 1234
REACT_APP_AUTO_LOGIN_NAME="Meu Nome"      # padrão: Infor
```

Após ajustar as variáveis, reinicie o servidor (`yarn start`) para aplicar as mudanças.

