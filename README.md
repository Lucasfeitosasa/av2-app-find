# Achados e Perdidos

Aplicativo Flutter/Dart para divulgar e consultar objetos perdidos ou encontrados no campus, conforme a avaliação 2 da disciplina Programação para Dispositivos Móveis (UESPI).

## Integrante

- Lucas Feitosa de Andrade

## Funcionalidades

- Lista registros remotos do mais recente para o mais antigo e permite atualizar por gesto de puxar ou pelo botão no topo.
- Exibe nome, descrição, local, situação e data/hora de cadastro.
- Cadastra objetos perdidos ou encontrados com validação dos campos obrigatórios e limites de 60 caracteres para nome e 200 para descrição.
- Mostra carregamento, impede envios duplicados, informa falhas de conexão e permite tentar novamente.
- Usa Material 3 e interface em português.


## Armazenamento remoto

O app usa a API REST do Supabase. O plano Free atende ao requisito de serviço sem custo. A URL do projeto e a chave pública **Publishable** são fornecidas em tempo de execução. A chave é própria para uso no cliente; nunca inclua uma chave **Secret** no app.

### Preparar o projeto Supabase

1. Crie um projeto no plano Free em [supabase.com](https://supabase.com/).
2. No SQL Editor, execute:

```sql
create table public.items (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 60),
  description text not null check (char_length(description) between 1 and 200),
  location text not null check (char_length(trim(location)) > 0),
  status text not null check (status in ('perdido', 'encontrado')),
  created_at timestamptz not null default now()
);

alter table public.items enable row level security;

revoke all on table public.items from anon, authenticated;
grant usage on schema public to anon;
grant select, insert on table public.items to anon;

create policy "Public can read items"
  on public.items for select to anon using (true);

create policy "Public can add items"
  on public.items for insert to anon with check (true);

```

3. Em **Project Settings → API Keys**, copie o **Project URL** e a chave **Publishable** (`sb_publishable_...`). Não use a chave **Secret** (`sb_secret_...`).

Como a avaliação não exige autenticação, os registros podem ser lidos e inseridos publicamente. Cadastre apenas dados demonstrativos, sem informações pessoais ou sensíveis. A política permite somente leitura e inserção; não permite edição nem exclusão.

Em **Integrations → Data API**, confirme que o schema `public` está exposto. Os `GRANT`s acima liberam apenas leitura e inserção da tabela `items` para o papel `anon`; a RLS aplica as políticas correspondentes.

## Configuração e execução

Instale o Flutter SDK e confirme `flutter doctor`. Na raiz do projeto, execute:

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_SUA_CHAVE
```

No PowerShell, a continuação pode ser escrita assim:

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_SUA_CHAVE
```

