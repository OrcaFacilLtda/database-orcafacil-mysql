# Regras de Negócio do OrçaFácil

### 👤 Cadastro de Usuários

- Existem **3 tipos de usuários**: `cliente`, `prestador` e `admin`.
- No cadastro, o usuário deve informar:
  - `nome`
  - `email`
  - `senha`
  - `tipo_usuario`
  - (opcional) `foto de perfil`
- Usuários do tipo `cliente` ou `prestador`:
  - Devem ser **aprovados manualmente** (`aprovado = TRUE`) antes de usarem o sistema.
- Usuários do tipo `admin`:
  - **Não precisam de aprovação** e podem executar ações administrativas.

---

### 👥 Relacionamentos Específicos por Tipo de Usuário

- Um `cliente` é vinculado à tabela `cliente` através de `usuario.id`.
- Um `prestador` é vinculado à tabela `prestador` através de `usuario.id` e pode ter:
  - Uma **descrição**
  - Uma **nota média**

---

### 📌 Solicitação de Serviço

- Um `cliente` pode **criar solicitações de serviço** com:
  - `título`
  - `descrição`
- A solicitação passa por diferentes etapas:
  - `aguardando_confirmacao_servico`
  - `agendada_visita`
  - `negociando`
  - `em_atendimento`
  - `finalizada`
  - `cancelada`
- O status geral da solicitação pode ser:
  - `aberta`
  - `fechada`

---

### 💰 Orçamentos

- `Prestadores` podem enviar **orçamentos** para as solicitações abertas.
- Cada orçamento inclui:
  - `valor`
  - `prazo_dias`
  - `status`: `pendente`, `aceito`, `recusado`
- Um orçamento pode conter **materiais necessários** via a tabela `material_orcamento`, com:
  - `nome_material`
  - `quantidade`
  - `unidade`
  - `observações` (opcional)

---

### ✅ Confirmações

- Após envio do orçamento, o sistema exige **confirmações mútuas**:
  - Cliente e prestador devem confirmar:
    - O **valor** do serviço
    - A **visita técnica**
  - Também é necessário confirmar:
    - Que o **atendimento foi realizado**
    - Que o **pagamento foi feito**
- Essas confirmações garantem que ambas as partes estão de acordo antes de avançar.

---

### ⭐ Avaliações

- Após o serviço ser concluído, **cliente e prestador** podem se avaliar.
- Cada avaliação contém:
  - `nota` de 1 a 5
  - `comentário`
- A `nota_media` do prestador pode ser atualizada conforme novas avaliações são recebidas.

---

### 🚨 Denúncias

- Qualquer usuário pode **denunciar outro usuário** por:
  - Mau comportamento
  - Problemas com o atendimento
- A denúncia possui:
  - `tipo`
  - `descrição`
  - `status`: `pendente`, `resolvida`, `arquivada`
- **Admins** podem aplicar **ações administrativas**:
  - Advertências
  - Suspensões
  - Outras penalidades
- As ações são registradas na tabela `acao_admin`.

