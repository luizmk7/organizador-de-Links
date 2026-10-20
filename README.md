# Estúdio — Organizador de Links

Organizador simples para duas pessoas: empresas, links gerais, busca, edição e importação dos links antigos. Sem cadastro ou login. Os dados são compartilhados e salvos no Supabase.

## Publicar manualmente na Vercel

1. Na Vercel, clique em **Add New → Project**.
2. Importe **luizmk7/organizador-de-Links**, branch **main**.
3. Mantenha **Root Directory** na raiz do repositório.
4. **Framework Preset: Other**.
5. **Output Directory: dist**. Os comandos de instalação e build ficam vazios.
6. Clique em **Deploy**.

O arquivo `vercel.json` já define essas configurações. Não é necessário instalar pacotes, executar build ou cadastrar variáveis de ambiente. O projeto Supabase atual já está configurado.

## Primeiro acesso ao novo endereço

O navegador trata o novo domínio da Vercel como outro site. Na primeira abertura, pode aparecer o campo **Cole aqui o link completo recebido**.

1. Cole nesse campo o link exclusivo completo que você recebeu na conversa — o endereço que contém `?acesso=...`.
2. Clique em **Abrir meu organizador**.
3. Use **Copiar acesso** para enviar ao seu amigo o link já com o domínio da Vercel.

Também é possível abrir `https://SEU-SITE.vercel.app/?acesso=SUA_CHAVE_EXISTENTE`, usando a mesma chave do link original. O banco continua sendo o mesmo: os links salvos na nuvem já estarão disponíveis.

A chave de acesso não está neste repositório. Quem tiver o link completo pode ver, adicionar, editar e excluir os links compartilhados. Não publique esse endereço no README ou no código.

## Links antigos no navegador

Dados salvos apenas no navegador do site anterior não migram entre domínios. Abra o site anterior e use **Importar links** para enviá-los ao Supabase; depois abra a Vercel. Os dados que já estão no Supabase não precisam de importação.

## Estrutura

- `dist/index.html`: página principal.
- `dist/style.css`: visual e responsividade.
- `dist/app.js`: organização, acesso e chamadas ao Supabase.
- `dist/supabase.js`: Supabase JS 2.102.0, incluído localmente.
- `vercel.json`: configuração de publicação.
- `database/shared-access.sql`: referência do esquema já aplicado. Não executar novamente no banco atual.

## Banco de dados

Projeto: `lrfnugrmjdwkbeleqsxi`.

O navegador usa apenas a chave **publishable**, que pode aparecer em um cliente web. Nenhuma chave `service_role`, senha de banco ou chave de acesso ao espaço está no código.

A função `public.organizer_shared` valida a chave exclusiva e chama uma função interna com operações delimitadas. As tabelas ficam em `organizer_private`, com RLS e sem permissões diretas para visitantes. A chave é armazenada no banco apenas como hash SHA-256.

Mudanças são gravadas por link, evitando substituir toda a lista quando duas pessoas editam. A lista atualiza ao voltar à janela ou clicar em **Atualizar**. É necessário estar conectado à internet para salvar.

## Desenvolvimento e verificações

Sirva `dist` com um servidor HTTP estático. Para verificar a sintaxe: `node --check dist/app.js`.

Foram testados leitura, criação, edição, exclusão e rejeição de chave inválida pela API real do Supabase. A configuração foi preparada para a Vercel; o deploy será feito manualmente pelo proprietário.
