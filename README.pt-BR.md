# SQL Reconciliation Lab — guia em português

Conciliação com PostgreSQL, CTEs e funções de janela. Os dados simulam duplicidade, estorno recebido antes de um evento antigo e identificadores iguais em empresas distintas. Executa localmente com PGlite e não acessa nenhum banco real.

## Executar

Node.js 24+ and npm. PGlite runs PostgreSQL locally in WebAssembly; no database account or Docker required.

```sh
npm ci
npm test
npm run demo
```

## O que observar

A saída contém quatro faturas: uma conciliada, duas com falta e uma com excesso. O estorno prevalece pelo número de sequência do provedor, não pela ordem de chegada.

## Origem e limites

Projeto novo, criado com assistência de IA para este portfólio. Todos os dados são fictícios. Não contém código de clientes, configurações de produção, credenciais ou histórico dos sistemas existentes.

Os detalhes técnicos, contratos e limitações estão no [README principal](README.md) e em [ARCHITECTURE.md](ARCHITECTURE.md). É uma demonstração educacional; não deve ser apresentada como produto implantado em clientes. Licença MIT para o código original; dependências mantêm suas próprias licenças.
