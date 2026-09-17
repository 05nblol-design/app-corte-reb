# Indicadores Zaraplast — Painel Industrial Corte & Rebobinamento

Aplicativo Flutter desenvolvido para monitoramento em tempo real dos indicadores de produção, pesagem, aparas (% sobre a produção), acompanhamento de liderança e metas de corte/rebobinamento da **Zaraplast**.

---

## 🚀 Principais Recursos ("Melhorado")

- **Painel em 4 Quadrantes Estratégicos**:
  1. **Transferência**: Pesado Hoje (10.582 kg) e Transferência Mensal (67.098 kg) com barras de progresso e ritmo vs meta.
  2. **Aparas — % sobre a Produção**: Tabela com controle rigoroso da meta de 3,0% (dia industrial 6h às 6h) por turno, dia e mês com destaque no total do Setor.
  3. **Acompanhamento Liderança**: Metros no turno, hoje (destaque verde) e acumulado no mês para todas as máquinas BCR.
  4. **Corte & Rebobinamento**: Donut Gauge com cálculo de 4,3% Concluído vs 95,7% Restante e projeção da meta de 27.500.000 metros.
- **Modo TV / Wallboard**: Visualização de alto contraste em tela cheia para TVs no chão de fábrica.
- **Dark Mode & Light Mode**: Alternância suave entre temas escuro e claro.
- **Filtro de Turnos**: Alternância entre 1º Turno (06h-14h), 2º Turno (14h-22h), 3º Turno (22h-06h) e Consolidado do Dia.
- **Inspeção de Máquinas**: Clique em qualquer linha (ex: `BCR007` ou `BCR015`) para abrir o modal de detalhes técnicos (OEE, velocidade em m/min, operador, ordem de produção e gráfico de motivos de aparas).
- **Alertas em Tempo Real**: Notificações automáticas para desvios de metas e recordes de produtividade.

---

## 🛠️ Como Executar o Projeto Flutter

### Pré-requisitos
- [Flutter SDK](https://flutter.dev) (versão 3.10 ou superior)

### 1. Obter as dependências
```bash
flutter pub get
```

### 2. Executar no Navegador (Web / TV Dashboard)
```bash
flutter run -d chrome
```

### 3. Executar no Windows Desktop
```bash
flutter run -d windows
```

### 4. Executar no Android / iOS
```bash
flutter run -d android
# ou
flutter run -d ios
```

---

## 📂 Estrutura do Projeto

```
lib/
├── main.dart                          # Ponto de entrada do aplicativo
├── core/
│   ├── theme/
│   │   ├── app_colors.dart            # Paleta de cores oficial Zaraplast
│   │   └── app_theme.dart             # Configuração dos temas Dark e Light
│   └── utils/
│       ├── formatters.dart            # Formatação numérica brasileira (ex: 1.188.756)
│       └── responsive.dart            # Breakpoints adaptativos (Mobile, Tablet, Desktop)
├── models/
│   ├── machine_indicator.dart         # Modelo de dados de cada máquina BCR
│   ├── transfer_indicator.dart        # Modelo para pesagem diária e mensal
│   └── alert_model.dart               # Modelo de alertas operacionais
├── providers/
│   └── indicators_state.dart          # Gerenciamento de estado e simulação em tempo real
├── widgets/
│   ├── custom_donut_gauge.dart        # Gráfico Donut estilizado com CustomPainter
│   ├── header_nav_bar.dart            # Barra superior com status ao vivo e filtros
│   ├── transfer_card.dart             # Card de Transferência
│   ├── scrap_table_card.dart          # Tabela de % de Aparas
│   ├── leadership_card.dart           # Acompanhamento de Liderança
│   ├── corte_rebobinamento_card.dart  # Card de Corte & Rebobinamento
│   ├── machine_detail_dialog.dart     # Modal de diagnóstico da máquina
│   └── alerts_dialog.dart             # Central de alertas de fábrica
└── screens/
    └── dashboard_screen.dart          # Tela principal do Dashboard
```
