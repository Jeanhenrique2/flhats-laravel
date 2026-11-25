<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>FL hats</title>
</head>
<body>
  <div id="app">
    <h1>FL hats</h1>
    <p>Sistema online de reforma de chapéus · Quatá, SP</p>
    <p id="status">Carregando...</p>
  </div>

  <script>
    const el = document.querySelector('#status');

    async function carregarStatus() {
      try {
        const res = await fetch('/api/health');
        const dados = await res.json();
        const dataHora = new Date(dados.timestamp).toLocaleString('pt-BR');
        el.textContent = `Status da API: ${dados.status} (${dataHora})`;
      } catch (erro) {
        el.textContent = 'Status da API: indisponível';
      }
    }

    carregarStatus();
  </script>
</body>
</html>