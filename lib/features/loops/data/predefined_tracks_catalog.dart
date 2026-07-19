import '../../../core/settings/cubit/settings_state.dart';
import '../domain/entities/predefined_track_template.dart';

/// Hardcoded interview-track templates filtered by the user's onboarding goal.
abstract final class PredefinedTracksCatalog {
  static List<PredefinedTrackTemplate> forGoal(
    String goalId,
    AppLanguage language,
  ) {
    final es = language == AppLanguage.spanish;
    return switch (goalId) {
      'bigTech' => _bigTech(es),
      'consulting' => _consulting(es),
      'banking' => _banking(es),
      'startup' => _startup(es),
      'productManager' => _productManager(es),
      _ => const [],
    };
  }

  static List<PredefinedTrackTemplate> _bigTech(bool es) => [
        PredefinedTrackTemplate(
          id: 'bigtech_google_swe',
          goalId: 'bigTech',
          title: es ? 'Software Engineer' : 'Software Engineer',
          company: 'Google',
          jobDescription: es
              ? 'Puesto de Software Engineer en Google. Evalúan estructuras de datos y algoritmos (arrays, trees, graphs), diseño de sistemas a escala, calidad de código y comunicación clara. Espera 1–2 problemas de coding con trade-offs, preguntas de complejidad y un caso ligero de system design. Cultura de impacto, ownership y colaboración cross-funcional.'
              : 'Software Engineer role at Google. They assess data structures and algorithms (arrays, trees, graphs), large-scale system design, code quality, and clear communication. Expect 1–2 coding problems with trade-offs, complexity questions, and a light system-design case. Culture of impact, ownership, and cross-functional collaboration.',
        ),
        PredefinedTrackTemplate(
          id: 'bigtech_meta_swe',
          goalId: 'bigTech',
          title: es ? 'Software Engineer' : 'Software Engineer',
          company: 'Meta',
          jobDescription: es
              ? 'Software Engineer en Meta. Enfoque en coding rápido y correcto, estructuras de datos, y product sense técnico. Preguntas sobre impacto en productos usados por millones, debugging y trade-offs de rendimiento. Valoran velocidad de ejecución, claridad al explicar decisiones y trabajo en equipos de producto.'
              : 'Software Engineer at Meta. Focus on fast, correct coding, data structures, and technical product sense. Questions on impact for products used by millions, debugging, and performance trade-offs. They value execution speed, clarity when explaining decisions, and work with product teams.',
        ),
        PredefinedTrackTemplate(
          id: 'bigtech_amazon_swe',
          goalId: 'bigTech',
          title: es ? 'Software Development Engineer' : 'Software Development Engineer',
          company: 'Amazon',
          jobDescription: es
              ? 'SDE en Amazon. Combina coding (algoritmos, OOP) con Leadership Principles: ownership, customer obsession, dive deep. Espera historias STAR de proyectos, un problema de coding y preguntas de diseño o escalabilidad. Demuestra métricas de impacto y decisiones bajo ambigüedad.'
              : 'SDE at Amazon. Combines coding (algorithms, OOP) with Leadership Principles: ownership, customer obsession, dive deep. Expect STAR stories from projects, a coding problem, and design or scalability questions. Show impact metrics and decisions under ambiguity.',
        ),
        PredefinedTrackTemplate(
          id: 'bigtech_apple_swe',
          goalId: 'bigTech',
          title: es ? 'Software Engineer' : 'Software Engineer',
          company: 'Apple',
          jobDescription: es
              ? 'Software Engineer en Apple. Énfasis en calidad de producto, atención al detalle, APIs limpias y pensamiento de usuario. Coding + diseño de componentes, privacidad y rendimiento en dispositivos. Valoran colaboración multidisciplinar y explicar trade-offs de UX/técnica con precisión.'
              : 'Software Engineer at Apple. Emphasis on product quality, attention to detail, clean APIs, and user-centric thinking. Coding plus component design, privacy, and on-device performance. They value cross-disciplinary collaboration and precise UX/technical trade-off explanations.',
        ),
        PredefinedTrackTemplate(
          id: 'bigtech_microsoft_swe',
          goalId: 'bigTech',
          title: es ? 'Software Engineer' : 'Software Engineer',
          company: 'Microsoft',
          jobDescription: es
              ? 'Software Engineer en Microsoft. Coding con DS&A, diseño de servicios cloud o cliente, y mentalidad de crecimiento. Preguntas sobre colaboración, feedback y proyectos de impacto. Espera problemas de coding, un diseño de sistema moderado y ejemplos de cómo elevaste a tu equipo.'
              : 'Software Engineer at Microsoft. Coding with DS&A, cloud or client service design, and growth mindset. Questions on collaboration, feedback, and impact projects. Expect coding problems, a moderate system design, and examples of how you elevated your team.',
        ),
        PredefinedTrackTemplate(
          id: 'bigtech_netflix_ml',
          goalId: 'bigTech',
          title: es ? 'Machine Learning Engineer' : 'Machine Learning Engineer',
          company: 'Netflix',
          jobDescription: es
              ? 'ML Engineer en Netflix. Evalúan fundamentos de ML (supervised/unsupervised, métricas, overfitting), pipelines de datos, A/B testing y producción de modelos a escala. Coding en Python, diseño de sistemas de recomendación o ranking, y cultura de libertad y responsabilidad. Explica experimentos y trade-offs de latencia vs precisión.'
              : 'ML Engineer at Netflix. They assess ML fundamentals (supervised/unsupervised, metrics, overfitting), data pipelines, A/B testing, and productionizing models at scale. Python coding, recommendation or ranking system design, and a freedom-and-responsibility culture. Explain experiments and latency vs accuracy trade-offs.',
        ),
      ];

  static List<PredefinedTrackTemplate> _consulting(bool es) => [
        PredefinedTrackTemplate(
          id: 'consulting_mckinsey_assoc',
          goalId: 'consulting',
          title: es ? 'Associate' : 'Associate',
          company: 'McKinsey',
          jobDescription: es
              ? 'Associate en McKinsey. Case interviews estructurados (profitability, market entry, M&A), PEI (experiencia personal e impacto), y comunicación clara con frameworks MECE. Practica síntesis al final del case, hipótesis drive y matemáticas de negocio. Valoran liderazgo, influencia y resolución de problemas ambiguos.'
              : 'Associate at McKinsey. Structured case interviews (profitability, market entry, M&A), PEI (personal experience and impact), and clear MECE communication. Practice end-of-case synthesis, hypothesis-driven thinking, and business math. They value leadership, influence, and solving ambiguous problems.',
        ),
        PredefinedTrackTemplate(
          id: 'consulting_bcg_consultant',
          goalId: 'consulting',
          title: es ? 'Consultant' : 'Consultant',
          company: 'BCG',
          jobDescription: es
              ? 'Consultant en BCG. Cases con énfasis en creatividad, insights accionables y fit cultural. Combina case structured + behavioral sobre colaboración y impacto. Demuestra pensamiento crítico, priorización y cómo comunicar recomendaciones a un cliente senior en 60 segundos.'
              : 'Consultant at BCG. Cases emphasizing creativity, actionable insights, and cultural fit. Combines structured case plus behavioral on collaboration and impact. Show critical thinking, prioritization, and how you communicate recommendations to a senior client in 60 seconds.',
        ),
        PredefinedTrackTemplate(
          id: 'consulting_bain_assoc',
          goalId: 'consulting',
          title: es ? 'Associate Consultant' : 'Associate Consultant',
          company: 'Bain',
          jobDescription: es
              ? 'Associate Consultant en Bain. Cases enfocados en resultados, ownership y trabajo en equipo (Answer First). Behavioral sobre resultados concretos y feedback. Practica market sizing, profitability y un case de growth. Valoran energía, humildad y orientación a resultados.'
              : 'Associate Consultant at Bain. Cases focused on results, ownership, and teamwork (Answer First). Behavioral on concrete outcomes and feedback. Practice market sizing, profitability, and a growth case. They value energy, humility, and results orientation.',
        ),
        PredefinedTrackTemplate(
          id: 'consulting_deloitte_sc',
          goalId: 'consulting',
          title: es ? 'Strategy Consultant' : 'Strategy Consultant',
          company: 'Deloitte',
          jobDescription: es
              ? 'Strategy Consultant en Deloitte. Cases de estrategia y transformación digital, behavioral sobre liderazgo y clientes. Evalúan estructura, comunicación ejecutiva y manejo de stakeholders. Incluye sizing, competitive analysis y recomendaciones implementables.'
              : 'Strategy Consultant at Deloitte. Strategy and digital-transformation cases, behavioral on leadership and clients. They assess structure, executive communication, and stakeholder management. Includes sizing, competitive analysis, and implementable recommendations.',
        ),
        PredefinedTrackTemplate(
          id: 'consulting_accenture_strat',
          goalId: 'consulting',
          title: es ? 'Strategy Analyst' : 'Strategy Analyst',
          company: 'Accenture Strategy',
          jobDescription: es
              ? 'Strategy Analyst en Accenture Strategy. Cases de operaciones y tecnología + fit. Preguntas sobre priorización, data-driven decisions y colaboración con equipos tech. Practica un case de cost reduction y uno de go-to-market; explica trade-offs entre velocidad y rigor analítico.'
              : 'Strategy Analyst at Accenture Strategy. Operations and technology cases plus fit. Questions on prioritization, data-driven decisions, and collaboration with tech teams. Practice a cost-reduction and a go-to-market case; explain trade-offs between speed and analytical rigor.',
        ),
        PredefinedTrackTemplate(
          id: 'consulting_kearney_assoc',
          goalId: 'consulting',
          title: es ? 'Business Analyst' : 'Business Analyst',
          company: 'Kearney',
          jobDescription: es
              ? 'Business Analyst en Kearney. Cases intensivos en operaciones y supply chain, con énfasis en números limpios y recomendaciones prácticas. Behavioral de impacto en proyectos reales. Demuestra estructura, calm under pressure y síntesis clara para el cliente.'
              : 'Business Analyst at Kearney. Operations- and supply-chain-heavy cases with emphasis on clean numbers and practical recommendations. Behavioral on impact in real projects. Show structure, calm under pressure, and clear client-facing synthesis.',
        ),
      ];

  static List<PredefinedTrackTemplate> _banking(bool es) => [
        PredefinedTrackTemplate(
          id: 'banking_gs_analyst',
          goalId: 'banking',
          title: es ? 'Investment Banking Analyst' : 'Investment Banking Analyst',
          company: 'Goldman Sachs',
          jobDescription: es
              ? 'IB Analyst en Goldman Sachs. Técnico: accounting, DCF, comps, LBO básico, merger math. Behavioral: teamwork bajo presión, atención al detalle, motivación por finance. Espera walk-through de un deal hipotético, preguntas de valoración y por qué Goldman / por qué banking.'
              : 'IB Analyst at Goldman Sachs. Technical: accounting, DCF, comps, basic LBO, merger math. Behavioral: teamwork under pressure, attention to detail, motivation for finance. Expect a hypothetical deal walk-through, valuation questions, and why Goldman / why banking.',
        ),
        PredefinedTrackTemplate(
          id: 'banking_jpm_ibd',
          goalId: 'banking',
          title: es ? 'IBD Analyst' : 'IBD Analyst',
          company: 'JPMorgan',
          jobDescription: es
              ? 'IBD Analyst en JPMorgan. Valoración (DCF, multiples), tres estados financieros, y fit con cultura de banca. Preguntas de deals recientes del sector, hours/attitude y storytelling de liderazgo. Demuestra precisión numérica y comunicación clara de un pitch corto.'
              : 'IBD Analyst at JPMorgan. Valuation (DCF, multiples), three financial statements, and cultural fit. Questions on recent sector deals, hours/attitude, and leadership storytelling. Show numerical precision and clear communication of a short pitch.',
        ),
        PredefinedTrackTemplate(
          id: 'banking_ms_markets',
          goalId: 'banking',
          title: es ? 'Markets Analyst' : 'Markets Analyst',
          company: 'Morgan Stanley',
          jobDescription: es
              ? 'Markets Analyst en Morgan Stanley. Productos de markets (equities, fixed income), market awareness, y behavioral de resiliencia. Preguntas sobre qué mueve mercados hoy, un trade idea y cómo explicas riesgo a un cliente. Valoran curiosidad, calma y pensamiento rápido.'
              : 'Markets Analyst at Morgan Stanley. Markets products (equities, fixed income), market awareness, and resilience behavioral. Questions on what moves markets today, a trade idea, and how you explain risk to a client. They value curiosity, calm, and quick thinking.',
        ),
        PredefinedTrackTemplate(
          id: 'banking_citi_analyst',
          goalId: 'banking',
          title: es ? 'Investment Banking Analyst' : 'Investment Banking Analyst',
          company: 'Citi',
          jobDescription: es
              ? 'IB Analyst en Citi. Técnico de valoración y accounting, más behavioral sobre colaboración global y manejo de deadlines. Practica un LBO simple, comps y “walk me through a DCF”. Explica motivación por el coverage group y un deal que te interese.'
              : 'IB Analyst at Citi. Valuation and accounting technicals plus behavioral on global collaboration and deadline management. Practice a simple LBO, comps, and “walk me through a DCF”. Explain motivation for the coverage group and a deal that interests you.',
        ),
        PredefinedTrackTemplate(
          id: 'banking_bofa_analyst',
          goalId: 'banking',
          title: es ? 'Investment Banking Analyst' : 'Investment Banking Analyst',
          company: 'Bank of America',
          jobDescription: es
              ? 'IB Analyst en Bank of America. Enfoque en fundamentos de valuation, pitch books y fit cultural. Preguntas técnicas + behavioral de ownership y learning agility. Prepara un elevator pitch de ti mismo, un sector thesis y un case corto de M&A rationale.'
              : 'IB Analyst at Bank of America. Focus on valuation fundamentals, pitch books, and cultural fit. Technical plus behavioral on ownership and learning agility. Prepare a self elevator pitch, a sector thesis, and a short M&A rationale case.',
        ),
        PredefinedTrackTemplate(
          id: 'banking_evercore_analyst',
          goalId: 'banking',
          title: es ? 'Restructuring / M&A Analyst' : 'Restructuring / M&A Analyst',
          company: 'Evercore',
          jobDescription: es
              ? 'Analyst en Evercore (boutique). Técnico avanzado de M&A y restructuring básico, atención extrema al detalle y narrativa de deals. Behavioral sobre por qué boutique vs bulge bracket. Demuestra profundidad analítica, humildad y capacidad de trabajar con senior bankers.'
              : 'Analyst at Evercore (boutique). Advanced M&A technicals and basic restructuring, extreme attention to detail, and deal storytelling. Behavioral on why boutique vs bulge bracket. Show analytical depth, humility, and ability to work with senior bankers.',
        ),
      ];

  static List<PredefinedTrackTemplate> _startup(bool es) => [
        PredefinedTrackTemplate(
          id: 'startup_fullstack_b',
          goalId: 'startup',
          title: es ? 'Full-Stack Engineer' : 'Full-Stack Engineer',
          company: es ? 'Startup Serie B' : 'Series B Startup',
          jobDescription: es
              ? 'Full-Stack Engineer en startup Serie B. Evalúan shipping rápido, ownership de features end-to-end, stack moderno (API + front) y pragmatismo. Preguntas de trade-offs MVP vs calidad, debugging en producción y cómo priorizas con producto. Cultura de alta autonomía y feedback directo.'
              : 'Full-Stack Engineer at a Series B startup. They assess fast shipping, end-to-end feature ownership, modern stack (API + front), and pragmatism. Questions on MVP vs quality trade-offs, production debugging, and how you prioritize with product. Culture of high autonomy and direct feedback.',
        ),
        PredefinedTrackTemplate(
          id: 'startup_backend_scaleup',
          goalId: 'startup',
          title: es ? 'Backend Engineer' : 'Backend Engineer',
          company: es ? 'Scaleup fintech' : 'Fintech scaleup',
          jobDescription: es
              ? 'Backend Engineer en scaleup fintech. APIs, bases de datos, confiabilidad y seguridad básica de pagos. Coding práctico + diseño de un servicio simple. Preguntas sobre incidentes, métricas y cómo escalas un sistema con pocos ingenieros. Valoran claridad y sesgo a la acción.'
              : 'Backend Engineer at a fintech scaleup. APIs, databases, reliability, and basic payments security. Practical coding plus simple service design. Questions on incidents, metrics, and how you scale a system with few engineers. They value clarity and bias to action.',
        ),
        PredefinedTrackTemplate(
          id: 'startup_mobile_growth',
          goalId: 'startup',
          title: es ? 'Mobile Engineer' : 'Mobile Engineer',
          company: es ? 'Startup consumer' : 'Consumer startup',
          jobDescription: es
              ? 'Mobile Engineer (iOS/Android/Flutter) en startup consumer. Calidad de UX, performance, release cycles y experimentación. Preguntas de arquitectura mobile, crashes, y colaboración con diseño. Demuestra un feature que enviaste y cómo mediste impacto.'
              : 'Mobile Engineer (iOS/Android/Flutter) at a consumer startup. UX quality, performance, release cycles, and experimentation. Questions on mobile architecture, crashes, and design collaboration. Show a feature you shipped and how you measured impact.',
        ),
        PredefinedTrackTemplate(
          id: 'startup_founding_eng',
          goalId: 'startup',
          title: es ? 'Founding Engineer' : 'Founding Engineer',
          company: es ? 'Startup early-stage' : 'Early-stage startup',
          jobDescription: es
              ? 'Founding Engineer en early-stage. Amplitud técnica, product sense, y capacidad de construir desde cero con ambigüedad total. Behavioral de ownership extremo, hiring/mentoría temprana y priorización brutal. Explica cómo elegirías stack, qué cortarías del MVP y cómo validarías con usuarios.'
              : 'Founding Engineer at an early-stage startup. Technical breadth, product sense, and building from scratch under total ambiguity. Behavioral on extreme ownership, early hiring/mentoring, and brutal prioritization. Explain how you’d choose a stack, what you’d cut from the MVP, and how you’d validate with users.',
        ),
        PredefinedTrackTemplate(
          id: 'startup_devops_platform',
          goalId: 'startup',
          title: es ? 'Platform / DevOps Engineer' : 'Platform / DevOps Engineer',
          company: es ? 'Startup B2B SaaS' : 'B2B SaaS startup',
          jobDescription: es
              ? 'Platform/DevOps en B2B SaaS. CI/CD, infra como código, observabilidad y costo cloud. Casos de incident response y cómo empoderas a equipos de producto. Valoran automatización, documentación breve y trade-offs de velocidad vs estabilidad.'
              : 'Platform/DevOps at a B2B SaaS startup. CI/CD, infrastructure as code, observability, and cloud cost. Incident-response cases and how you empower product teams. They value automation, brief documentation, and speed vs stability trade-offs.',
        ),
        PredefinedTrackTemplate(
          id: 'startup_data_growth',
          goalId: 'startup',
          title: es ? 'Data Engineer' : 'Data Engineer',
          company: es ? 'Startup growth-stage' : 'Growth-stage startup',
          jobDescription: es
              ? 'Data Engineer en startup growth-stage. Pipelines ETL/ELT, calidad de datos, warehouses y métricas de producto. Preguntas de modelado, latencia vs costo, y cómo soportas growth/marketing con datos confiables. Demuestra un pipeline que construiste y su impacto en decisiones.'
              : 'Data Engineer at a growth-stage startup. ETL/ELT pipelines, data quality, warehouses, and product metrics. Questions on modeling, latency vs cost, and how you support growth/marketing with reliable data. Show a pipeline you built and its impact on decisions.',
        ),
      ];

  static List<PredefinedTrackTemplate> _productManager(bool es) => [
        PredefinedTrackTemplate(
          id: 'pm_google_pm',
          goalId: 'productManager',
          title: 'Product Manager',
          company: 'Google',
          jobDescription: es
              ? 'PM en Google. Product sense, analytical thinking, ejecución y liderazgo técnico sin autoridad formal. Casos de diseño de producto, métricas (guardrails), priorización y trade-offs. Behavioral de influencia y ambigüedad. Estructura: clarificar, usuarios, solución, métricas, riesgos.'
              : 'PM at Google. Product sense, analytical thinking, execution, and technical leadership without formal authority. Product design cases, metrics (guardrails), prioritization, and trade-offs. Behavioral on influence and ambiguity. Structure: clarify, users, solution, metrics, risks.',
        ),
        PredefinedTrackTemplate(
          id: 'pm_meta_apm',
          goalId: 'productManager',
          title: es ? 'Associate Product Manager' : 'Associate Product Manager',
          company: 'Meta',
          jobDescription: es
              ? 'APM en Meta. Product sense orientado a crecimiento y engagement, cases de feature design, y behavioral de ownership. Preguntas de métricas de éxito, experimentos A/B y cómo priorizas con ingeniería. Demuestra curiosidad por productos sociales y pensamiento de sistema.'
              : 'APM at Meta. Growth- and engagement-oriented product sense, feature design cases, and ownership behavioral. Questions on success metrics, A/B experiments, and how you prioritize with engineering. Show curiosity about social products and systems thinking.',
        ),
        PredefinedTrackTemplate(
          id: 'pm_stripe_pm',
          goalId: 'productManager',
          title: 'Product Manager',
          company: 'Stripe',
          jobDescription: es
              ? 'PM en Stripe. Producto B2B/developer, claridad técnica, y rigor analítico. Cases de API/product design, pricing/packaging ligero, y stakeholder management con sales/eng. Valoran precisión en el lenguaje, empatía con developers y decisiones data-informed.'
              : 'PM at Stripe. B2B/developer product, technical clarity, and analytical rigor. API/product design cases, light pricing/packaging, and stakeholder management with sales/eng. They value precise language, empathy for developers, and data-informed decisions.',
        ),
        PredefinedTrackTemplate(
          id: 'pm_amazon_pm',
          goalId: 'productManager',
          title: 'Product Manager',
          company: 'Amazon',
          jobDescription: es
              ? 'PM en Amazon. Customer obsession, working backwards, y Leadership Principles. Cases de producto + behavioral STAR. Espera definir un PR/FAQ mental, métricas de input/output y un plan de lanzamiento. Demuestra ownership y pensamiento de largo plazo.'
              : 'PM at Amazon. Customer obsession, working backwards, and Leadership Principles. Product cases plus STAR behavioral. Expect to outline a mental PR/FAQ, input/output metrics, and a launch plan. Show ownership and long-term thinking.',
        ),
        PredefinedTrackTemplate(
          id: 'pm_airbnb_pm',
          goalId: 'productManager',
          title: 'Product Manager',
          company: 'Airbnb',
          jobDescription: es
              ? 'PM en Airbnb. Product sense de marketplace, trust & safety, y experiencia de huésped/anfitrión. Cases de diseño, growth loops y trade-offs de UX vs monetización. Behavioral de colaboración con diseño e investigación. Explica cómo medirías calidad de matching o retención.'
              : 'PM at Airbnb. Marketplace product sense, trust & safety, and guest/host experience. Design cases, growth loops, and UX vs monetization trade-offs. Behavioral on collaboration with design and research. Explain how you’d measure matching quality or retention.',
        ),
        PredefinedTrackTemplate(
          id: 'pm_uber_pm',
          goalId: 'productManager',
          title: 'Product Manager',
          company: 'Uber',
          jobDescription: es
              ? 'PM en Uber. Operaciones + producto en marketplace de movilidad. Cases de pricing, supply/demand, métricas operativas y priorización bajo incertidumbre. Behavioral de ejecución en entornos caóticos. Demuestra claridad con números y empatía por riders y drivers.'
              : 'PM at Uber. Operations plus product in a mobility marketplace. Cases on pricing, supply/demand, operational metrics, and prioritization under uncertainty. Behavioral on execution in chaotic environments. Show numerical clarity and empathy for riders and drivers.',
        ),
      ];
}
