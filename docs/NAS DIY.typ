#set text(font: "CMU Serif", region: "es", lang:  "es")
#set page(
  width: 21.6cm,
  height: 33cm,
  margin: 2.5cm
)
#set par(justify: true)
#show link: underline


#v(7cm)

#align(center)[
  #text("Network Attached Storage (NAS) Do-It-Yourself (DIY)", size: 18pt)

  #text(
    "Construyendo un sistema NAS para organizar correctamente nuestra vida digital",
    size: 14pt
  )
  #v(3cm)
  #text("Daniel Ramos", size: 14pt)

  #text("17 de junio de 2025", size: 14pt)
]

#pagebreak()

#outline()

#pagebreak()

= Introducción

== Objetivo del documento

== ¿Qué es un NAS?

Un *Network Attached Storage (NAS)* es un dispositivo de almacenamiento de datos conectado a una red, diseñado para proporcionar acceso centralizado, compartido y seguro a archivos y datos digitales. A diferencia de un disco duro externo convencional, que se conecta directamente a un único ordenador, un NAS se integra en la red local y permite que múltiples usuarios o dispositivos accedan simultáneamente a sus contenidos a través de protocolos estándar como SMB/CIFS, NFS, FTP, o incluso servicios web como WebDAV o interfaces RESTful.

Desde el punto de vista arquitectónico, un NAS es un pequeño servidor especializado cuyo único o principal propósito es servir almacenamiento a través de la red. Puede estar basado en hardware propietario o en hardware genérico con un sistema operativo optimizado para esta función. Internamente, el NAS gestiona sistemas de archivos, configuraciones de seguridad, control de usuarios y, en muchos casos, servicios complementarios como copias de seguridad automáticas, sincronización en la nube, o multimedia en streaming.

En términos funcionales, el NAS representa una evolución en la organización del almacenamiento personal y profesional, al permitir:

- Centralizar la información dispersa en múltiples dispositivos.
- Facilitar el acceso remoto a los datos desde cualquier ubicación con conexión a internet.
- Mejorar la seguridad y la redundancia de los datos mediante configuraciones RAID y sistemas de archivos avanzados.
- Automatizar tareas de copia de seguridad y sincronización.

El concepto de NAS ha evolucionado desde entornos empresariales hacia el ámbito doméstico, respondiendo a la creciente necesidad de gestionar grandes volúmenes de información digital (fotos, vídeos, documentos, copias de seguridad de móviles y portátiles) de forma autónoma, económica y respetuosa con la privacidad.

== ¿Por qué un NAS?

En las últimas décadas, el crecimiento exponencial del contenido digital personal —especialmente fotografías, vídeos y documentos— ha generado una dependencia creciente de servicios de almacenamiento en la nube. Plataformas como *iCloud* (Apple) y *Google Drive* (Google) se han convertido en soluciones ampliamente adoptadas, debido a su integración directa con dispositivos móviles y sistemas operativos. En particular, la activación de un nuevo terminal, ya sea Android o iOS, suele incluir la configuración automática de un plan gratuito de respaldo en la nube.

No obstante, estos planes gratuitos ofrecen una *capacidad de almacenamiento limitada* que, en la mayoría de los casos, resulta insuficiente en un corto plazo. La necesidad de adquirir planes de pago recurrentes para ampliar el espacio se convierte así en una condición inevitable para quienes deseen mantener una copia completa y segura de su contenido personal.

Con el auge de los servicios de almacenamiento en la nube, dos actores dominan el mercado de soluciones personales: Apple iCloud y Google One. Ambos ofrecen escalabilidad progresiva mediante suscripciones mensuales, pero presentan estrategias de precios que merecen ser analizadas en detalle.

A continuación, se presenta una tabla comparativa de las distintas capacidades disponibles, junto con su coste mensual y el precio equivalente por terabyte:

#pagebreak()

#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  inset: 10pt,
  table.header(
    [*Servicio*], [*Capacidad*], [*Precio mensual*], [*Precio/TB*]
  ),
  table.cell(rowspan: 5)[iCloud],
  "50 GB", "0,99 €", "20,27 €",
  "200 GB", "2,99 €", "15,30 €",
  "2 TB", "9,99 €", "4,99 €",
  "6 TB", "29,99 €", "4,99 €",
  "12 TB", "59,99 €", "4,99 €",
  table.cell(rowspan: 3)[Google One],
  "100 GB", "1,99 €", "20,38 €",
  "200 GB", "2,99 €", "15,31 €",
  "2 TB", "9,99 €", "4,99 €",
)

La tabla pone de manifiesto *una fuerte discontinuidad entre los planes intermedios y los de alta capacidad*. Tanto en iCloud como en Google One, existe una *brecha considerable entre los 200 GB y los 2 TB*, sin planes que cubran capacidades intermedias a precios proporcionales. Esta discontinuidad podría interpretarse como una estrategia de retención: una vez que el usuario alcanza el límite de 200 GB, y habiendo delegado ya una parte significativa de su vida digital en la plataforma, la opción más sencilla y psicológicamente accesible es *aceptar el salto al plan de 2 TB*, a pesar del incremento de coste mensual.

Asimismo, resulta interesante observar que *a partir del plan de 2 TB*, los precios por terabyte *se estabilizan en torno a los 5 €/TB/mes*, sin disminuir proporcionalmente al aumentar la capacidad. Esto sugiere que la economía de escala no se traslada al usuario final, reforzando el modelo de ingresos sostenido en la fidelización y dependencia de largo plazo.

Según varios estudios #cite(<sedera2018digital>), las personas tienden a acumular grandes volúmenes de datos personales debido a una creciente dependencia de dispositivos digitales, aplicaciones móviles y plataformas en la nube. Este fenómeno, conocido como acaparamiento digital (digital hoarding), conlleva la conservación casi indiscriminada de fotografías, vídeos, documentos, capturas de pantalla y otros tipos de archivos.

El estudio estima que una persona promedio puede llegar a generar y almacenar del orden de 3,7 TB de datos personales a lo largo de su vida digital activa. Bajo este supuesto, y adoptando un enfoque conservador en el que cada miembro de una unidad familiar contrate individualmente el plan de 2 TB por 9,99 € al mes, el coste agregado alcanzaría:

- *9,99 € × 5 personas = 49,95 €/mes*
- *49,95 € × 12 meses = 599,40 €/año*

Desde esta perspectiva, el desarrollo de una solución de almacenamiento autónoma —*un NAS DIY (Do-It-Yourself)*— podría resultar una *alternativa económicamente sostenible* y tecnológicamente viable. El objetivo de este proyecto es diseñar y construir un sistema NAS cuya inversión inicial y *coste de mantenimiento anual se sitúe por debajo del umbral de 600 €*, sin renunciar a características clave como la accesibilidad remota, la redundancia, la escalabilidad y la privacidad.

Además del componente económico, existen *otras motivaciones fundamentales* para optar por una solución NAS personal:

- *Control total sobre los datos*, sin depender de infraestructuras de terceros.
- *Privacidad y soberanía digital*, evitando el tratamiento automatizado de contenidos sensibles por parte de corporaciones.
- *Capacidad de personalización*, adaptando el sistema a necesidades específicas (por ejemplo, backup automatizado de dispositivos móviles, sincronización con escritorios, gestión de archivos multimedia históricos, etc.).
- *Escalabilidad progresiva*, incorporando nuevos discos o servicios sin cambiar de plataforma.

En este contexto, el presente documento plantea un análisis integral para la construcción de un sistema NAS DIY que permita a cualquier persona gestionar su vida digital de manera eficaz, autónoma y ética.

= Discos Duros

La elección de los discos duros constituye uno de los aspectos más *críticos en el diseño de un sistema NAS*, ya que de ella depende en gran medida la fiabilidad, longevidad y consistencia del almacenamiento. Aunque en el mercado existen múltiples tipos de discos con diferentes propósitos —desde unidades optimizadas para alto rendimiento hasta modelos diseñados para bajo consumo energético—, en el contexto de un NAS doméstico o semiprofesional, el criterio prioritario debe ser la *durabilidad*.

A diferencia de otros entornos donde puede priorizarse la velocidad de acceso o la eficiencia energética, un sistema NAS requiere unidades que ofrezcan una operación sostenida durante ciclos prolongados de lectura y escritura, así como una resistencia comprobada frente a fallos mecánicos o errores de superficie. En este sentido, resulta preferible sacrificar cierto rendimiento o eficiencia energética si ello implica mejorar la confiabilidad a largo plazo.

Entre los factores que influyen directamente en esta durabilidad, uno de los más relevantes es el *tipo de tecnología de grabación magnética empleada por el disco*. En la actualidad, la mayoría de discos duros mecánicos (HDD) utilizan una de tres técnicas fundamentales:

- *CMR (Conventional Magnetic Recording)*
- *SMR (Shingled Magnetic Recording)*
- *PMR (Perpendicular Magnetic Recording)*

Cada una de estas tecnologías presenta características propias que afectan de forma significativa el comportamiento del disco bajo cargas típicas de un NAS. Por ello, en los siguientes apartados se abordará esta distinción en detalle, junto con una revisión de modelos recomendados y criterios técnicos para seleccionar las unidades más adecuadas para un entorno de almacenamiento en red.

== Tipos de discos duros

#figure(
  image("./images/cmr-vs-smr.jpg", width: 60%),
  caption: [ Comparativa entre las tecnologías de grabación CMR y SMR, destacando las diferencias en la disposición de las pistas. Fuente: #link("https://recuperaciondedatos.com.mx/cual-es-la-diferencia-entre-discos-pmr-cmr-y-smr/", "recuperaciondedatos.com.mx") ],
)

La diferencia fundamental entre CMR/PMR y SMR radica en la disposición de las pistas magnéticas en el plato del disco. En los discos *convencionales (CMR/PMR)*, las pistas se escriben una al lado de otra con un pequeño *espacio de separación* entre ellas, mientras que en los discos *SMR* cada pista nueva se *superpone parcialmente* a la anterior, de forma similar a las tejas de un tejado. Esta superposición permite incrementar la *densidad de datos* (más bits por pulgada cuadrada) y, por tanto, ofrecer más capacidad por disco, pero tiene implicaciones importantes en el *rendimiento de escritura* y la *fiabilidad* a largo plazo --- especialmente bajo cargas de trabajo intensivas y continuas típicas de un NAS.

=== SMR (Shingled Magnetic Recording)

La grabación magnética escalonada (*SMR*) es una técnica diseñada para *incrementar la densidad de almacenamiento* superponiendo parcialmente las pistas de datos, lo que permite *eliminar los espacios entre ellas* y alcanzar hasta un *20 % más de capacidad* por disco frente a tecnologías convencionales como *PMR/CMR*. No obstante, esta ganancia conlleva una *mayor complejidad interna*, ya que las pistas no pueden sobrescribirse directamente: cualquier modificación requiere *escritura diferida* y una posterior *reorganización secuencial*, ejecutada durante períodos de inactividad. Este proceso, transparente para el usuario, hace que *los discos SMR dependan críticamente de los tiempos muertos* para mantener un rendimiento aceptable. En contextos como los NAS, caracterizados por accesos frecuentes y escritura continua, esta dependencia puede conducir a *fuertes degradaciones de rendimiento* y comprometer la *fiabilidad operativa del sistema*.


==== Ventajas de SMR

- *Mayor capacidad por unidad:* Al superponer parcialmente las pistas, los discos SMR permiten almacenar más datos por superficie, logrando *capacidades significativamente superiores* a las de sus equivalentes CMR, con un *coste por terabyte más bajo* y menor número de componentes mecánicos.

- *Eficiencia en datos fríos o de solo lectura:* Son una opción adecuada para *almacenamientos de tipo backup o archivo*, donde los datos se escriben una vez y se accede a ellos de forma esporádica. En estos escenarios, su *alta densidad* puede aprovecharse sin que su menor rendimiento de escritura represente un problema.

==== Limitaciones de SMR

- *Rendimiento de escritura limitado:* El diseño escalonado impide sobrescrituras directas, lo que obliga a reorganizar pistas en segundo plano. Esto se traduce en *baja velocidad sostenida*, especialmente bajo cargas prolongadas, y una *latencia irregular* en escrituras aleatorias.

- *Inadecuados para uso continuo 24/7*: En entornos con escritura constante, como NAS multiusuario o de vigilancia, los discos SMR tienden a *saturar su caché* y degradar el rendimiento, siendo *incapaces de mantener un flujo estable de operaciones*.

- *Problemas en reconstrucción de RAID:* Su comportamiento en matrices RAID degradadas es *notoriamente deficiente*. Las pausas internas para reorganización pueden provocar *errores de paridad*, reconstrucciones extremadamente lentas, o incluso fallos completos del proceso.

- *Menor fiabilidad y vida útil:* El estrés adicional sobre los mecanismos internos y la complejidad de la gestión de pistas hacen que, en condiciones exigentes, los discos SMR presenten *una tasa de fallos superior* y una *durabilidad reducida* respecto a unidades CMR comparables.

=== CMR (Conventional Magnetic Recording)

La grabación magnética convencional (CMR) es el método tradicional en el que las pistas se *escriben sin traslaparse*, utilizando la tecnología de grabación perpendicular (PMR) estándar. En esencia, *CMR y PMR son lo mismo* en las unidades modernas: todos los discos duros actuales usan grabación perpendicular, y cuando apareció SMR se comenzó a llamar _“convencional” (CMR)_ al método perpendicular con separación entre pistas. A continuación, se detallan sus ventajas y desventajas en entornos NAS:

==== Ventajas de CMR en NAS

Los discos con tecnología CMR destacan por ofrecer un rendimiento constante tanto en lectura como en escritura, incluso bajo cargas 24/7. Su diseño evita reorganizaciones internas, lo que permite *reescritura directa sin penalizaciones*. Además, ofrecen *alta fiabilidad y durabilidad*, con tasas de fallo muy bajas y garantías prolongadas. Por todo ello, son plenamente compatibles con configuraciones RAID, soportando sin problemas procesos exigentes como la reconstrucción de volúmenes degradados.

==== Limitaciones de CMR

A cambio de esa estabilidad, *sacrifican densidad de almacenamiento*: requieren más espacio físico por terabyte, lo que implica un mayor coste por TB. Además, la tecnología tiene un *límite práctico de escalabilidad*, por lo que para capacidades muy elevadas se recurre a soluciones alternativas como SMR o HAMR.

=== PMR (Perpendicular Magnetic Recording)

La grabación magnética perpendicular (PMR) es la base tecnológica sobre la que se construyen los discos CMR modernos. Introducida a mediados de los 2000, reemplazó al método longitudinal (LMR) al alinear los bits verticalmente en lugar de horizontalmente, lo que permitió triplicar la densidad de almacenamiento sin comprometer la estabilidad magnética. Esta disposición mejora la retención de datos al reducir las interferencias entre bits, formando un sistema más robusto frente a desmagnetizaciones espontáneas. Gracias a estas cualidades, PMR resolvió los límites de integridad que presentaba LMR, posibilitando bits más pequeños y fiables en el tiempo. En la actualidad, casi todos los discos duros emplean PMR de algún modo, siendo el estándar en unidades CMR. Su equilibrio entre densidad y confiabilidad lo ha consolidado durante casi dos décadas como la opción preferente en entornos de alta demanda, como servidores NAS y centros de datos.

==== Ventajas de PMR

La tecnología PMR destaca por su *madurez y fiabilidad*, con una larga trayectoria en entornos de uso continuo. Ofrece *alta estabilidad magnética a largo plazo*, lo que asegura la conservación de datos durante años, y permite una operación sencilla y eficiente gracias a que las pistas no se solapan, evitando reorganizaciones internas. Esto se traduce en un *rendimiento constante*, ideal para sistemas NAS y configuraciones RAID exigentes.

==== Limitaciones de PMR

Su principal limitación es la *menor densidad de almacenamiento* respecto a tecnologías como SMR, lo que implica discos con menos capacidad por unidad física y un *costo por TB ligeramente superior*. Además, en términos de eficiencia energética y de espacio, puede requerir más recursos para alcanzar capacidades similares.

== Conclusiones: ¿Qué tecnología ofrece mayor longevidad en NAS?

Teniendo en cuenta lo anterior, para un uso en NAS orientado a *larga duración y seguridad de los datos*, las tecnologías *CMR/PMR* se destacan como la opción más confiable. Sus discos presentan un rendimiento predecible y han demostrado *menores tasas de fallo* con el paso de los años en comparación con las unidades SMR. De hecho, es ampliamente reconocido en la comunidad técnica que es *preferible adquirir unidades PMR/CMR* para configuraciones NAS, especialmente cuando se utilizarán volúmenes RAID o aplicaciones de alta carga, debido a que *SMR acarrea problemas de rendimiento y fiabilidad* bajo esas condiciones. En un NAS, donde la prioridad es que los datos estén siempre accesibles y seguros, un disco CMR/PMR brindará mayor tranquilidad: soportará escrituras aleatorias 24/7, reconstruirá RAID sin sorpresas y en general *durará más años operando sin incidencias graves*.

En conclusión, *CMR/PMR es la tecnología de grabación magnética que ofrece mayor longevidad y confiabilidad en entornos NAS*, respaldada por su desempeño estable y un historial positivo en operación 24/7. Los discos SMR, aunque aportan mayor densidad, sacrifican desempeño y potencian factores de riesgo (ralentizaciones, errores en RAID, posible menor vida útil), por lo que *se desaconsejan para NAS exigentes* orientados a conservación de datos a largo plazo. Siempre que la integridad y disponibilidad de la información sea prioritaria, optar por unidades *no SMR (es decir, CMR/PMR)* será la estrategia adecuada. En el contexto de un NAS, donde “más vale prevenir que lamentar”, invertir en discos duros CMR/PMR robustos garantiza una base de almacenamiento *más sólida y duradera* para sus datos.

== Discos duros recomendados

Una vez establecida la superioridad de la tecnología *CMR* en términos de fiabilidad frente a su contraparte SMR, resulta pertinente identificar modelos de discos duros que ofrezcan un rendimiento óptimo en entornos de alta exigencia como lo es un sistema NAS.

Para garantizar la *máxima durabilidad operativa*, los criterios fundamentales en la selección de discos incluyen:

- Un *alto índice de carga de trabajo anual* (workload rate), medido en terabytes escritos por año (TB/año).
- Un *elevado tiempo medio entre fallos (MTBF, por sus siglas en inglés)*, expresado en horas.
- La pertenencia a gamas *"enterprise" o profesionales*, específicamente diseñadas para funcionamiento continuo (24/7) y uso intensivo.

A continuación se muestra una tabla comparativa con los principales modelos disponibles en el mercado que cumplen estos requisitos:

#table(
  columns: (auto, 1fr, 1fr, 1fr),
  inset: 10pt,
  table.header(
    [*Modelo*],
    [*Workload*],
    [*MTBF*],
    [*Precio*],
  ),
  table.cell([#link("https://amzn.eu/d/81yfjiD")[
    Seagate Exos X10
  ]]), "550 TB/año", "2.5M h", "149,90 €",
  table.cell([#link("https://amzn.eu/d/jb5ZYtA")[
    WD Ultrastar DC HC330
  ]]), "550 TB/año", "2.5M h", "292,99 €",
  table.cell([#link("https://amzn.eu/d/81yfjiD")[
    Toshiba MG
  ]]), "550 TB/año", "2.5M h", "326,37 €",
  table.cell([#link("https://amzn.eu/d/8vHKF4D")[
    WD Red Pro
  ]]), "300 TB/año", "1M h", "286,00 €",
  table.cell([#link("https://amzn.eu/d/81yfjiD")[
    Seagate IronWolf Pro
  ]]), "300 TB/año", "1,2M h", "259,00 €",
)

De los cinco modelos comparados, los tres primeros —*Seagate Exos X10*, *WD Ultrastar DC HC330* y *Toshiba MG*— destacan por ofrecer:

- *Una carga de trabajo anual de hasta 550 TB*, lo cual los hace aptos para entornos con múltiples usuarios, respaldo frecuente y replicación intensiva de datos.
- *Un MTBF de 2,5 millones de horas*, que supone una fiabilidad considerablemente superior a la media del mercado doméstico.
- Soporte explícito para funcionamiento continuo (*24/7*) y compatibilidad con entornos RAID, condiciones comunes en sistemas NAS.

Aunque todos ellos ofrecen prestaciones equivalentes en cuanto a fiabilidad y resistencia, el factor *económico* es determinante en proyectos de infraestructura doméstica o de pequeña escala. En el momento de la redacción del presente informe, el modelo *Seagate Exos X10* se posiciona como la opción más asequible, manteniendo al mismo tiempo los estándares técnicos más exigentes. Por tanto, se recomienda su adquisición como disco base para la configuración de un NAS DIY de alto rendimiento y bajo coste de mantenimiento.

= NAS propietarios vs NAS DIY

En el ámbito del almacenamiento en red, el ecosistema de dispositivos NAS puede dividirse en dos grandes enfoques: *los sistemas propietarios* y *las soluciones de construcción propia o "DIY" (_Do-It-Yourself_)*. Ambas alternativas tienen como objetivo ofrecer un punto de acceso centralizado y persistente a los datos digitales, pero difieren significativamente en términos de filosofía de diseño, control, escalabilidad, costes y flexibilidad.

Por un lado, los *NAS propietarios* constituyen dispositivos preensamblados y comercializados por fabricantes especializados, tales como *Synology*, *QNAP* o *Asustor*. Estos equipos incluyen hardware optimizado y sistemas operativos diseñados específicamente para facilitar la configuración y gestión del almacenamiento en red. Dentro de cada marca, se ofrecen múltiples modelos que varían según su potencia de procesamiento, capacidad de expansión, funcionalidades adicionales (como virtualización o multimedia) y rango de precios.

Por otro lado, las *soluciones NAS DIY* implican la *selección, montaje y configuración manual* de todos los componentes del sistema, desde el hardware (placa base, procesador, discos, chasis, etc.) hasta el sistema operativo y los servicios de red. Esta aproximación exige un mayor nivel de conocimiento técnico por parte del usuario, pero permite una personalización total, así como un mayor control sobre la seguridad, el rendimiento y los costes a largo plazo.

En las secciones siguientes, se presentará un análisis comparativo de ambas opciones, evaluando sus principales *ventajas y desventajas*, con el fin de fundamentar la elección de un enfoque DIY como alternativa viable, sostenible y ética frente a las soluciones propietarias del mercado.

== NAS propietarios


Los sistemas NAS propietarios son soluciones comerciales llave en mano, ofrecidas por fabricantes como *Synology*, *QNAP*, *Asustor*, entre otros. Se caracterizan por su enfoque en la *facilidad de uso*, su diseño compacto y la integración entre hardware y software. Estas soluciones están orientadas principalmente a usuarios sin experiencia técnica, pequeñas oficinas o entornos domésticos que buscan una infraestructura de almacenamiento accesible y de rápida puesta en marcha.

=== Ventajas de los NAS propietarios

- *Ensamblaje y configuración predeterminada*: Estos dispositivos vienen completamente ensamblados y preconfigurados, lo que elimina la necesidad de seleccionar componentes o realizar ajustes a bajo nivel.
- *Experiencia “plug and play”*: El usuario puede comenzar a utilizar el dispositivo prácticamente desde el momento de su conexión a la red local, sin requerir conocimientos técnicos avanzados.
- *Soporte técnico y garantía centralizada*: Al tratarse de soluciones integradas, los fabricantes ofrecen soporte técnico específico, incluyendo reparaciones, actualizaciones de firmware y reemplazos en caso de fallo.
- *Formato compacto y optimizado*: El diseño industrial de estos equipos tiende a ser compacto, silencioso y estéticamente adecuado para entornos domésticos o de oficina, con integración eficiente de componentes y reducción del cableado visible.

=== Desventajas de los NAS propietarios

- *Falta de control sobre el sistema operativo*: Los usuarios no tienen acceso directo al sistema base. Si el fabricante cesa el soporte o retrasa actualizaciones críticas de seguridad, el dispositivo puede quedar expuesto o limitado sin posibilidad de intervención.
- *Dependencia del software propietario*: La arquitectura cerrada impide modificaciones profundas o la instalación de servicios externos no soportados oficialmente. Tecnologías comunes como contenedores Docker, ZFS o scripts personalizados pueden no estar disponibles o estar restringidas.
- *Presencia de software innecesario (bloatware)*: Muchos dispositivos incluyen utilidades y aplicaciones preinstaladas que consumen recursos sin aportar valor al usuario técnico, dificultando la personalización.
- *Sobrecarga de interfaz gráfica*: La abundante interfaz de administración está pensada para usuarios no técnicos, lo cual puede resultar innecesario o incluso limitante para usuarios avanzados que prefieren trabajar desde terminal o con automatizaciones.
- *Opacidad y potencial riesgo para la privacidad*: El usuario no tiene visibilidad sobre qué procesos internos se ejecutan, ni garantías sobre la no inspección de sus datos, dado que el sistema operativo es cerrado.
- *Eficiencia energética subóptima*: Muchos dispositivos comerciales utilizan arquitecturas x86 con componentes estándar (como placas base y memoria RAM convencionales), lo que puede suponer un mayor consumo energético frente a alternativas ARM optimizadas.
- *Costo elevado*: Al incluir márgenes comerciales, diseño industrial y soporte integrado, los precios de estos dispositivos suelen ser notablemente superiores a los de un sistema equivalente montado de forma independiente.
- *Limitaciones en reparaciones y actualizaciones*: La arquitectura cerrada implica dependencia de piezas del fabricante. En caso de fallo de la placa base o necesidad de expansión, las opciones de actualización están restringidas al ecosistema propietario.

== NAS DIY

Las soluciones NAS DIY suponen la *construcción manual de un sistema de almacenamiento*, seleccionando y ensamblando cada componente según los requisitos del proyecto. Esta aproximación otorga al usuario un control completo sobre el hardware, el sistema operativo y la arquitectura de servicios, lo que permite optimizar el dispositivo tanto en términos de rendimiento como de eficiencia energética y costes.

=== Ventajas de un NAS DIY

- *Control total sobre el sistema operativo y actualizaciones*: El usuario puede elegir libremente la distribución Linux o BSD que prefiera, garantizando un ciclo de vida prolongado del sistema y una gestión proactiva de las actualizaciones de seguridad.
- *Alta personalización del stack tecnológico*: Se puede seleccionar el sistema de contenedores (Docker, Podman, LXC), los servicios específicos (por ejemplo: Immich para fotos, Jellyfin para multimedia) y las configuraciones exactas según las necesidades del entorno.
- *Instalación mínima y sin software innecesario*: Al encargarse directamente de la instalación, el sistema solo contiene los componentes estrictamente requeridos, lo que mejora el rendimiento y reduce la superficie de ataque.
- *Optimización del hardware*: La libertad de elección permite optar por arquitecturas más eficientes como placas *ARM de bajo consumo*, o soluciones con soporte ECC, ventilación pasiva, y bajo ruido, ideales para entornos domésticos.
- *Optimización del software*: Es posible instalar sistemas operativos ligeros y orientados al servidor, sin entorno gráfico (headless), lo que reduce significativamente el uso de recursos.
- *Menor coste total*: Como se verá en los análisis económicos posteriores, un NAS DIY puede alcanzar un coste notablemente inferior frente a su equivalente propietario, sin renunciar a características de alta fiabilidad.
- *Modularidad y reparabilidad*: Todos los componentes —discos duros, unidades SSD, placa base, memoria, fuente de alimentación— son seleccionados de forma independiente, lo que facilita su sustitución, reparación o actualización a lo largo del tiempo.

=== Desventajas del NAS DIY

- *Elevada exigencia técnica inicial*: La construcción de un NAS DIY requiere conocimientos en administración de sistemas, redes, almacenamiento, sistemas de archivos, contenedores y seguridad. Esto puede suponer una barrera de entrada considerable para personas sin experiencia previa.
- *Configuración manual intensiva*: Cada elemento del sistema debe ser instalado y configurado manualmente: sistema operativo, configuración de red, gestión RAID o ZFS/Btrfs, políticas de backup, automatización de tareas, alertas y monitorización. Esta flexibilidad, aunque poderosa, implica una curva de aprendizaje elevada y una mayor inversión de tiempo.

== Mejores opciones de mercado

Con el fin de establecer una *comparación económica y funcional equilibrada* entre un sistema NAS DIY y una alternativa propietaria, es necesario identificar modelos comerciales que cuenten con especificaciones de hardware equiparables. Aunque no es posible una equivalencia absoluta debido a diferencias estructurales entre ambos enfoques —especialmente en cuanto a modularidad, eficiencia energética y escalabilidad—, es viable establecer un marco de análisis coherente si se normalizan ciertos criterios clave.

Para este estudio, se ha definido como referencia la configuración objetivo del NAS DIY descrita en capítulos posteriores, basada en los siguientes elementos:

- *Capacidad para 8 bahías (8-bay NAS)*
- *32 GB de memoria RAM*
- *CPU de cuatro núcleos de bajo consumo*

No obstante, en el mercado de dispositivos propietarios no es común encontrar modelos con *32 GB de RAM combinados con procesadores de bajo consumo*, ya que estos equipos tienden a priorizar *potencia y versatilidad generalista* por encima de la eficiencia energética o la modularidad. En consecuencia, la comparación se establece en términos de *características mínimamente equivalentes* en cuanto a capacidad, rendimiento bruto y soporte de servicios.

Las *opciones propietarias analizadas* en esta sección son las siguientes:

#table(
  columns: (auto, auto, auto, auto),
  inset: 10pt,
  table.header(
    [*Modelo*],
    [*CPU*],
    [*RAM*],
    [*Precio*],
  ),
  table.cell([#link("https://qloudea.com/synology-ds1821plus")[
    Synology DS1823xs+
  ]]), "AMD Ryzen V1500B 4 cores", "8GB DDR4", "1.176,90 €",
  table.cell([#link("https://www.pccomponentes.com/qnap-ts-873a-8gb-nas-8-bahias-negro")[
    QNAP TS-873A-8GB
  ]]), "AMD Ryzen V1500B 4 cores", "8GB DDR4", "1.269,00 €",
  table.cell([#link("https://www.amazon.es/Asustor-Lockerstor-Gen3-AS6808T-Almacenamiento/dp/B0DBYVPCZX?th=1")[
    Asustor Lockerstor 8 Gen3 AS6808T
  ]]), "AMD Ryzen V3C14 4 cores", "16GB DDR4", "1.849,90 €",
  table.cell([#link("https://qloudea.com/synology-ds1823xs")[
    Synology DS1823xs+
  ]]), "AMD Ryzen V1780B 4 cores", "8GB DDR4", "1.949,90 €",
  table.cell([#link("https://qloudea.com/qnap-tvs-h874-i7-32g")[
    QNAP TVS-h874-i7-32G
  ]]), "Intel Core i7-12700 12 cores", "32GB DDR4", "3.442,90 €",
)

== Conclusiones

Del análisis anterior se desprenden varias observaciones clave:

- *No existe en el mercado una configuración equivalente* a la propuesta de este proyecto NAS DIY, es decir, un sistema con *CPU de cuatro núcleos de bajo consumo*, *32 GB de RAM*, y *capacidad para 8 bahías*, a un coste razonable. Todos los modelos analizados priorizan el uso de procesadores potentes (generalmente x86 Ryzen o Intel Core), pensados para tareas de virtualización o multimedia avanzada, lo cual *eleva significativamente el precio final* del dispositivo.

- Aunque estas CPUs son adecuadas para entornos corporativos o multimedia, *no se ajustan a los requerimientos de este proyecto*, que no prevé una carga intensiva de procesamiento. En cambio, se busca un sistema optimizado para tareas concurrentes pero ligeras, como servicios en contenedores, sincronización de archivos, backups automatizados y acceso remoto básico.

- En este contexto, *la RAM adquiere un papel más importante que la CPU*, ya que permitirá alojar múltiples servicios y contenedores sin comprometer el rendimiento. Aumentar la RAM a 32 GB en dispositivos propietarios implica saltos de precio considerables, como se observa en el modelo *QNAP TVS-h874-i7-32G*, cuyo coste supera los *3.400 €* sin incluir discos.

- A partir de los precios observados, se puede establecer una *línea base conservadora de 1.200 €* como coste mínimo de adquisición para un NAS de 8 bahías en el mercado propietario (sin discos). Esta cifra se utilizará como umbral de referencia económica para evaluar la viabilidad del enfoque DIY.

Así, uno de los objetivos centrales de este trabajo será demostrar que es posible *diseñar y construir un NAS DIY con prestaciones adecuadas, personalización avanzada y menor consumo*, manteniendo el *coste total (chasis, placa, fuente de alimentación, RAM y CPU)* por debajo de dicha cifra, sin renunciar a fiabilidad ni escalabilidad.

= Almacenamiento y RAID

En cualquier sistema NAS, el subsistema de almacenamiento constituye su núcleo funcional, ya que es el encargado de *garantizar la integridad, disponibilidad y persistencia de los datos*. La fiabilidad del almacenamiento no depende únicamente de la calidad de los discos duros empleados, sino también de las *estrategias de redundancia y tolerancia a fallos* implementadas, así como del sistema de ficheros que gobierna la organización interna de los datos.

En este capítulo se abordarán dos dimensiones técnicas fundamentales para el diseño y puesta en marcha de un NAS robusto.

== Sistemas de ficheros

La elección del sistema de ficheros es un factor crítico que influye directamente en el rendimiento, la capacidad de recuperación ante errores, la compresión de datos, el soporte para instantáneas (_snapshots_) y la verificación de integridad. En este apartado se analizarán tres opciones relevantes: *Btrfs*, *ZFS*, y la combinación *MergeFS + SnapRAID*, cada una con sus ventajas, limitaciones y requisitos técnicos.

=== ZFS

*ZFS (Zettabyte File System)* es un sistema de ficheros avanzado con capacidades de gestión de volúmenes integradas, originalmente desarrollado por *Sun Microsystems* y actualmente mantenido por *OpenZFS* como un proyecto comunitario. A diferencia de los sistemas de archivos tradicionales, ZFS fue diseñado desde sus orígenes con el objetivo de proporcionar *integridad de datos de extremo a extremo*, *resiliencia frente a fallos*, y *escalabilidad masiva*, integrando funcionalidades que habitualmente requerían varias capas de software.

ZFS no es solo un sistema de archivos, sino un conjunto completo de tecnologías que gestionan tanto los datos como los dispositivos físicos subyacentes. Su enfoque es especialmente robusto y ha sido ampliamente adoptado en entornos de misión crítica, como centros de datos, servicios en la nube, servidores empresariales y sistemas de backup de alto rendimiento.

==== Características principales

ZFS incorpora un amplio conjunto de características que lo distinguen como una solución de almacenamiento de última generación:

- *Verificación de integridad con checksums*: ZFS calcula sumas de verificación para cada bloque de datos y metadatos. Ante cualquier lectura, compara el hash almacenado con el contenido leído, y si se detecta una corrupción, puede recuperar automáticamente los datos a partir de una copia redundante si está disponible.

- *Gestión de volúmenes integrada (ZFS pool)*: El sistema gestiona de forma unificada el espacio de almacenamiento físico a través de “pools” (vdevs), sin necesidad de herramientas externas como LVM o mdadm. Esto permite una asignación dinámica y flexible del espacio en disco.

- *Snapshots y clones*: ZFS permite crear snapshots instantáneos y consistentes de cualquier volumen, así como clones —versiones modificables de una snapshot—, lo cual es útil para backups, pruebas, y despliegues automatizados.

- *Compresión transparente*: Soporta compresión en tiempo real utilizando algoritmos como LZ4, zstd o gzip, permitiendo ahorrar espacio de forma efectiva sin comprometer el rendimiento.

- *RAID-Z (RAID-Z1, Z2 y Z3)*: ZFS implementa su propia versión de RAID (llamada RAID-Z), optimizada para evitar el problema del “write hole” (corrupciones por escritura parcial), y capaz de soportar una, dos o hasta tres fallas de disco sin pérdida de datos.

- *Scrubbing automático*: A través de procesos de “scrub”, ZFS verifica periódicamente la integridad de todos los datos almacenados, identificando errores silenciosos y corrigiéndolos automáticamente si se dispone de redundancia.

- *Escalabilidad extrema*: Soporta volúmenes de hasta 256 billones de zettabytes, decenas de miles de snapshots y millones de archivos, todo ello manteniendo una consistencia transaccional.

==== Ventajas en entornos NAS

ZFS es especialmente valioso en entornos NAS que priorizan la *consistencia, la fiabilidad a largo plazo y la capacidad de recuperación frente a fallos*. Su diseño transaccional garantiza que los datos nunca queden en un estado inconsistente, incluso ante apagones o reinicios inesperados. Las funcionalidades de snapshot y scrubbing son idóneas para automatizar políticas de backup y mantenimiento, mientras que la gestión de volúmenes integrada reduce la complejidad operativa.

Para usuarios que manejan volúmenes grandes de datos —como copias de seguridad incrementales, archivos multimedia en alta resolución o conjuntos de datos científicos— ZFS ofrece ventajas sustanciales respecto a sistemas como ext4 o incluso Btrfs, tanto en fiabilidad como en eficiencia a largo plazo.

==== Consideraciones y limitaciones

A pesar de sus numerosas ventajas, ZFS presenta ciertas *limitaciones importantes* que deben ser consideradas antes de su implementación en entornos domésticos o de bajo consumo:

- *Elevado consumo de memoria*: ZFS está diseñado para aprovechar grandes cantidades de RAM, especialmente cuando se usa *ARC (Adaptive Replacement Cache)* para acelerar el acceso a datos frecuentes. Se recomienda un mínimo de *8 GB de RAM*, y de forma ideal *1 GB de RAM por cada 1 TB de almacenamiento gestionado*. Esto lo convierte en una opción menos adecuada para sistemas con arquitectura ARM o bajo consumo energético.

- *No se recomienda usar TRIM en SSDs con ZFS sin precauciones*, ya que puede interferir con la integridad de las snapshots. Su uso en entornos con almacenamiento mixto requiere configuración cuidadosa.

- *Curva de aprendizaje*: La riqueza funcional de ZFS implica una complejidad técnica considerable. La sintaxis, los conceptos de diseño (pools, vdevs, datasets) y la gestión avanzada de snapshots o scrub pueden resultar intimidantes para personas sin experiencia previa en administración de sistemas Unix-like.

- *Licencia no compatible con el kernel de Linux*: ZFS está bajo licencia CDDL, lo cual impide su integración directa en el kernel Linux (GPL). Aunque existen soluciones como *OpenZFS sobre DKMS o ZFS-on-Linux*, esto puede presentar problemas de mantenimiento o compatibilidad en distribuciones muy personalizadas.


=== MergeFS + SnapRAID

La combinación de *MergeFS* y *SnapRAID* representa un enfoque alternativo al almacenamiento en red orientado a usuarios que priorizan la *flexibilidad, el bajo consumo de recursos y la facilidad de ampliación*, incluso por encima de la coherencia en tiempo real o la tolerancia inmediata a fallos. A diferencia de sistemas como ZFS o Btrfs, que ofrecen integración nativa de múltiples funciones avanzadas, esta solución se construye a partir de *herramientas independientes que cooperan de forma modular*, cada una con una responsabilidad claramente definida: *unificación del espacio lógico* (MergeFS) y *redundancia y recuperación ante fallos* (SnapRAID).

Esta aproximación es especialmente atractiva en entornos domésticos o semiprofesionales donde la mayoría de los datos son *estáticos o de acceso poco frecuente* (por ejemplo, fotos, vídeos, archivos multimedia personales o backups históricos), y donde la escalabilidad progresiva y el ahorro de costes son factores determinantes.

==== Características principales

*MergeFS* es una herramienta de espacio de usuarios que permite combinar múltiples sistemas de archivos montados en un único punto de montaje lógico. A diferencia de RAID, no requiere discos del mismo tamaño ni una inicialización destructiva del contenido. Funciona como una *capa de agregación lógica*, presentando al usuario una estructura unificada (por ejemplo, `/mnt/storage`) que en realidad está respaldada por múltiples directorios o dispositivos físicos (por ejemplo, `/mnt/disk1`, `/mnt/disk2`, etc.).

*SnapRAID*, por su parte, es una solución de *RAID basado en paridad y orientado a ficheros*, diseñada específicamente para entornos donde los datos cambian de forma esporádica. A diferencia del RAID tradicional, SnapRAID *no actúa en tiempo real*: calcula y actualiza la información de paridad manualmente, a través de comandos programados o tareas cron. Esto permite tolerancia a fallos en uno o varios discos (dependiendo del número de discos de paridad configurados) sin imponer penalizaciones en el rendimiento de escritura ni requerir discos idénticos.

Las características más destacadas de esta combinación son:

- *Soporte para discos heterogéneos*: MergeFS y SnapRAID permiten utilizar discos de diferentes tamaños, marcas o antigüedad sin necesidad de reformatear ni reconstruir arrays, lo cual maximiza la reutilización de hardware existente.
- *Redundancia configurable*: SnapRAID puede proteger contra la pérdida de hasta 6 discos simultáneamente, dependiendo de la cantidad de discos de paridad utilizados.
- *Tolerancia a fallos y recuperación de datos*: En caso de fallo de un disco de datos, SnapRAID puede reconstruir su contenido a partir de la paridad. Adicionalmente, puede verificar y reparar corrupciones silenciosas (bit rot) mediante comprobación periódica.
- *Escrituras no destructivas*: Al no operar en tiempo real, SnapRAID evita el riesgo del “write hole” común en RAIDs tradicionales.
- *Independencia de sistema de archivos subyacente*: Los discos gestionados por MergeFS y SnapRAID pueden estar formateados con cualquier sistema de archivos (ext4, XFS, Btrfs, etc.), lo que proporciona una gran libertad de elección.

==== Ventajas en entornos NAS

La combinación MergeFS + SnapRAID se adapta especialmente bien a entornos NAS donde:

- Los datos son *mayoritariamente inmutables*, como colecciones de medios, fotos familiares, backups o archivos históricos.
- Se desea mantener el *consumo de RAM y CPU al mínimo*, lo cual la hace compatible con arquitecturas ARM o sistemas de bajo consumo energético.
- Se requiere una solución *económica y progresivamente ampliable*, ya que permite añadir nuevos discos sin reconstrucción del sistema ni pérdida de datos.
- La prioridad es la *simplicidad operativa y modularidad*, más que la coherencia transaccional o el rendimiento de escritura en tiempo real.

Además, la separación entre el sistema de archivos y la capa de redundancia facilita la *auditoría, migración y desmontaje* del sistema sin depender de estructuras propietarias o complejas.

==== Consideraciones y limitaciones

Pese a sus múltiples ventajas, esta solución también presenta limitaciones importantes que deben ser evaluadas cuidadosamente:

- *No ofrece protección en tiempo real*: Si ocurre un fallo antes de ejecutar el proceso de sincronización (`snapraid sync`), los datos nuevos o modificados pueden perderse. Esto requiere una gestión activa mediante tareas cron frecuentes.
- *No protege contra fallos simultáneos durante escritura*: Al no ser transaccional, no garantiza coherencia si se produce una caída durante operaciones de escritura.
- *No es adecuado para cargas altamente dinámicas*: Bases de datos, contenedores o archivos en modificación constante no son buenos candidatos para esta solución.
- *Curva de aprendizaje moderada*: Aunque más simple que ZFS, requiere conocimientos sobre planificación de tareas, monitoreo de logs y verificación periódica (`scrub`).

En conclusión, MergeFS + SnapRAID constituye una solución *modular, ligera y rentable* para entornos NAS centrados en *almacenamiento estático, ampliación progresiva y consumo contenido de recursos*. Si bien no es adecuada para todo tipo de cargas de trabajo, se presenta como una alternativa estratégica para usuarios que desean *flexibilidad sin renunciar a cierta redundancia* y que son capaces de gestionar el sistema de forma activa.

=== BTRFS

*Btrfs (B-tree File System)* es un sistema de ficheros moderno diseñado para superar las limitaciones estructurales y funcionales de los sistemas de archivos tradicionales como *ext4*, *XFS* o *NTFS*. Su desarrollo fue iniciado por Oracle en 2007 y, desde entonces, ha sido adoptado por una creciente comunidad de desarrolladores y distribuidores Linux, hasta consolidarse como una opción avanzada y estable en numerosos entornos de producción.

A diferencia de los sistemas de ficheros convencionales que se centran exclusivamente en la organización de datos sobre discos individuales, Btrfs integra de forma nativa funciones que históricamente requerían herramientas externas o capas adicionales como LVM o RAID. Esto lo convierte en una solución integral que combina *sistema de archivos*, *volúmenes lógicos*, y *gestión de redundancia y snapshots* en una única capa coherente.

==== Características principales

Las funcionalidades más destacadas de Btrfs incluyen:

- *Snapshots (instantáneas)*: Btrfs permite crear instantáneas de sistemas de archivos de forma instantánea y sin interrupción del servicio. Estas instantáneas son *copy-on-write*, es decir, no duplican los datos hasta que se modifican, lo que las hace extremadamente eficientes en espacio.

- *Subvolúmenes*: Los subvolúmenes de Btrfs actúan como particiones lógicas internas que pueden ser gestionadas de forma independiente. Es posible realizar backups, replicaciones o snapshots específicos para cada subvolumen, lo cual otorga una granularidad muy útil en entornos NAS.

- *Integridad de datos por checksumming*: Btrfs implementa *sumas de verificación (checksums)* tanto para los datos como para la metadata. Esto permite detectar y corregir errores silenciosos de disco (bit rot) y verificar constantemente la integridad de los archivos almacenados.

- *RAID integrado*: Btrfs permite implementar configuraciones de RAID a nivel de sistema de archivos sin necesidad de software externo. Soporta los modos *RAID 0, 1, 10, 5 y 6*, aunque las configuraciones RAID 5 y 6 aún presentan advertencias de estabilidad en algunos casos de uso.

- *Balanceo y expansión dinámica*: Es posible añadir o retirar discos de un volumen Btrfs en tiempo real, sin interrupción del servicio, lo que facilita la escalabilidad progresiva de un NAS.

- *Compresión transparente*: Btrfs soporta compresión de datos en tiempo real mediante algoritmos como zlib, lzo o zstd, lo cual puede mejorar significativamente el uso eficiente del almacenamiento.

- *Detección y corrección automática de errores*: En configuraciones con redundancia, Btrfs puede detectar un error de lectura mediante checksums y corregirlo automáticamente desde la copia redundante, sin intervención del usuario.

==== Ventajas en entornos NAS

La integración nativa de snapshots, subvolúmenes y verificación de integridad convierte a Btrfs en un sistema de ficheros especialmente adecuado para sistemas NAS, donde la fiabilidad, trazabilidad de cambios y eficiencia del espacio son prioridades clave. Además, al estar completamente integrado en el kernel de Linux, no requiere módulos externos ni licencias propietarias.

Su compatibilidad con herramientas de backup como *`btrbk`*, *`snapper`* o *`send/receive`* permite diseñar esquemas de copia de seguridad automatizados y de bajo impacto, ideales para preservar el historial de archivos personales, bases de datos o configuraciones de contenedores.

Una de las ventajas operativas más relevantes de Btrfs frente a otros sistemas de archivos avanzados, como *ZFS*, es su *bajo consumo de memoria RAM*, lo que lo convierte en una opción especialmente adecuada para entornos con recursos limitados. Mientras que ZFS requiere habitualmente *mínimos de 8 GB o más de RAM* para funcionar correctamente —y hasta 1 GB por cada terabyte de almacenamiento como recomendación estándar—, Btrfs puede ejecutarse de forma *estable y eficiente en sistemas con apenas 1–2 GB de RAM*, sin sacrificar funcionalidades clave como snapshots, compresión o verificación de integridad.

==== Consideraciones y limitaciones

Pese a sus múltiples ventajas, es importante tener en cuenta algunas consideraciones técnicas:

- Las configuraciones *RAID 5 y 6* en Btrfs todavía presentan ciertos *riesgos de inconsistencia* bajo condiciones específicas de fallo de disco y deben evitarse en producción sin supervisión avanzada.
- No soporta aún *codificación por bloques (block-level deduplication)* de forma nativa, aunque se puede emplear `duperemove` o `bees` como soluciones externas.
- La gestión de snapshots puede generar fragmentación si no se automatiza adecuadamente su limpieza.

En resumen, Btrfs representa una solución moderna, robusta y versátil para sistemas NAS DIY, especialmente cuando se busca un equilibrio entre fiabilidad, automatización, eficiencia de espacio y control técnico. En comparación con ZFS, ofrece una curva de entrada más suave y menores requerimientos de memoria, lo que lo hace idóneo para entornos domésticos o de bajo consumo energético.

=== Conclusiones

Tras el análisis comparativo de los tres enfoques principales en cuanto a sistemas de ficheros avanzados —*ZFS*, *Btrfs* y *MergeFS + SnapRAID*— se pueden extraer una serie de conclusiones relevantes que orientan la elección del sistema más adecuado para el presente proyecto NAS DIY.

En primer lugar, *ZFS* demuestra ser una solución excepcional en contextos donde la *consistencia, la tolerancia a fallos y la integridad de datos* son requisitos absolutamente críticos. Su robusto diseño, el modelo de almacenamiento transaccional y su sistema de verificación continua lo convierten en la opción preferente para entornos empresariales o servidores de misión crítica. No obstante, estas virtudes conllevan también una serie de exigencias técnicas elevadas: *consumo elevado de memoria RAM*, mayor complejidad de administración, y necesidad de hardware de gama alta para alcanzar su máximo potencial. En un entorno doméstico o de bajo consumo energético, estos requisitos pueden resultar desproporcionados respecto al beneficio real obtenido.

En el extremo opuesto, la combinación *MergeFS + SnapRAID* representa una alternativa ligera, modular y flexible, ideal para sistemas basados en discos heterogéneos o hardware reutilizado. Sin embargo, dicha flexibilidad conlleva importantes compromisos. El hecho de que *no se ofrezca protección en tiempo real* ante fallos, que la redundancia dependa de tareas programadas, y que se requiera una intervención activa para mantener la integridad del sistema, lo hacen menos idóneo para un entorno que pretende mantener un *nivel profesional de fiabilidad*. Además, dado que en este proyecto se emplearán discos *enterprise-grade* nuevos y uniformes, la principal ventaja de MergeFS (aceptar discos de diferentes tipos y tamaños) queda fuera del escenario previsto.

Finalmente, *Btrfs* emerge como una *solución intermedia altamente equilibrada*, que combina muchas de las funcionalidades avanzadas de ZFS —como snapshots, verificación de integridad, subvolúmenes, y compresión— con un *consumo de recursos significativamente menor*, lo que permite su ejecución en plataformas más modestas y eficientes energéticamente. Aunque actualmente las configuraciones RAID 5 y 6 de Btrfs no son plenamente estables para entornos críticos, el uso de *RAID 1 o RAID 10* se considera plenamente funcional y fiable, y como se detallará en los apartados siguientes, puede proporcionar un nivel de redundancia suficiente para los objetivos de este sistema NAS.

En resumen, la elección de *Btrfs* para este proyecto responde a criterios de *eficiencia, robustez, sostenibilidad técnica y compatibilidad con hardware ligero*, lo cual permite alcanzar un nivel de fiabilidad próximo al de entornos empresariales, sin incurrir en los costes ni complejidades de soluciones como ZFS.

== Tipos de RAID

El concepto de *RAID (Redundant Array of Independent Disks)* constituye uno de los pilares fundamentales en la arquitectura de sistemas de almacenamiento resilientes. Su propósito es combinar múltiples discos físicos en una única unidad lógica, permitiendo así *mejorar el rendimiento, aumentar la capacidad de almacenamiento utilizable y, sobre todo, ofrecer tolerancia a fallos*. Dependiendo de la configuración elegida, el sistema RAID puede permitir que uno o varios discos fallen sin que se pierdan los datos, gracias a técnicas de replicación o de almacenamiento de paridad.

Existen múltiples niveles de RAID, cada uno con distintas propiedades en cuanto a *redundancia, eficiencia de espacio, velocidad de lectura/escritura y capacidad de recuperación ante fallos*. Desde configuraciones básicas como *RAID 0* o *RAID 1*, hasta esquemas más avanzados como *RAID 5*, *RAID 6* o *RAID 10*, cada variante representa un compromiso diferente entre fiabilidad y coste.

Dado que en este proyecto se ha optado por implementar *Btrfs* como sistema de archivos principal, es necesario *descartar aquellos niveles de RAID que no cuentan con un soporte maduro y estable dentro de su implementación interna*. A día de hoy, aunque Btrfs ofrece soporte para varios niveles de RAID, las configuraciones *RAID 5 y RAID 6* presentan limitaciones conocidas y advertencias por parte de la propia comunidad de desarrollo, especialmente en lo que respecta a la fiabilidad de recuperación ante fallos y a la integridad de metadatos en eventos de corrupción.

Por tanto, en el contexto de esta arquitectura, se considerarán únicamente los niveles de RAID *plenamente compatibles y recomendados por la comunidad Btrfs*.

=== Single

El modo *Single* en Btrfs representa la configuración más básica y directa del sistema de archivos, en la cual los datos y metadatos se almacenan sin aplicar ningún tipo de *replicación ni redundancia*. En esta modalidad, Btrfs actúa como un sistema de archivos convencional sobre un único dispositivo o sobre varios dispositivos sin organización de paridad ni espejado. Cada bloque de datos es escrito una sola vez y reside en un único lugar físico.

Desde el punto de vista operativo, Single *no proporciona tolerancia a fallos*. Si el disco (o uno de los discos en un volumen multicomponente sin configuración RAID) falla, los datos almacenados en él *se pierden irremediablemente*, ya que no existe ninguna copia redundante que permita su recuperación. Por tanto, esta configuración *no es adecuada para almacenar información crítica o insustituible* sin contar con un sistema de respaldo externo o complementario.

Una ventaja técnica de este modo es su *simplicidad*: no introduce sobrecarga de gestión asociada al cálculo de paridad o a la escritura simultánea en múltiples dispositivos. Esto puede traducirse en un rendimiento ligeramente superior para ciertas operaciones de escritura secuencial, aunque a costa de la seguridad de los datos.

=== RAID 1

El modo *RAID 1* en Btrfs implementa una estrategia de *espejado (mirroring)* de datos y metadatos entre dos o más dispositivos físicos. A diferencia de implementaciones tradicionales de RAID 1, en las que los datos se duplican entre dos discos, la versión de Btrfs ofrece una mayor flexibilidad al permitir *espejar bloques individuales* en múltiples dispositivos de forma granular, en lugar de copiar discos completos.

==== Principio de funcionamiento

En Btrfs, *cada bloque de datos y metadatos es escrito dos veces*, en dos dispositivos distintos del volumen. Esto proporciona una tolerancia inmediata a fallos: si uno de los discos deja de funcionar, el sistema puede recuperar de forma transparente la información desde su réplica.

El requisito mínimo para configurar RAID 1 en Btrfs es disponer de *al menos dos dispositivos*. Si se añaden más de dos, Btrfs continuará duplicando bloques entre pares de dispositivos, pero no extenderá la tolerancia a fallos más allá de un único fallo simultáneo. Es decir, con tres o más discos, RAID 1 en Btrfs *no funciona como RAID 1 n-way*, sino que mantiene siempre *dos copias* de cada bloque, independientemente del número total de discos.

==== Ventajas

- *Alta fiabilidad y recuperación ante fallos*: en caso de fallo de uno de los dispositivos, no se pierde información gracias al espejo en otro disco.
- *Verificación de integridad automática*: combinada con las sumas de verificación (checksums) de Btrfs, la redundancia permite *detectar y corregir errores silenciosos*.
- *Lectura paralela*: Btrfs puede leer bloques desde cualquiera de las copias, lo que mejora el rendimiento de lectura en operaciones concurrentes.
- *Compatibilidad con expansión dinámica*: se pueden añadir nuevos discos al volumen RAID 1, y redistribuir los datos con comandos de balance (`btrfs balance`) para mejorar la distribución física sin reiniciar el sistema ni perder datos.

==== Limitaciones

- *Uso de espacio*: RAID 1 ofrece únicamente el *50 % de la capacidad total de almacenamiento*. Por ejemplo, si se usan dos discos de 10 TB, el espacio útil será de 10 TB.
- *Tolerancia limitada a fallos múltiples*: al mantener solo dos copias de cada bloque, el sistema no está protegido ante la caída simultánea de dos discos que contengan el mismo bloque replicado.
- *Distribución de datos no simétrica en discos múltiples*: con tres o más dispositivos, la ubicación de las copias puede no estar completamente equilibrada, lo cual puede afectar al rendimiento en ciertos casos si no se reequilibra manualmente.

=== RAID 10 (1+0)

El modo *RAID 10* en Btrfs combina las ventajas del *striping* (distribución de bloques) y el *mirroring* (espejado), proporcionando una solución equilibrada entre *rendimiento, redundancia y escalabilidad*. A diferencia del RAID 10 clásico, implementado generalmente como RAID 1 + RAID 0 a nivel de bloques o de dispositivos, en Btrfs esta configuración se maneja de forma *nativa a nivel de sistema de archivos*, permitiendo una gestión más flexible de los datos y metadatos.

==== Principio de funcionamiento

En una configuración RAID 10 de Btrfs, cada bloque de datos se *duplica en dos dispositivos diferentes* (como en RAID 1), y adicionalmente los bloques se *distribuyen entre pares de discos (striping)*, lo que permite mejorar el rendimiento en operaciones de lectura y escritura concurrentes. Este enfoque requiere *al menos cuatro dispositivos* para funcionar correctamente, y escala de forma natural en múltiplos pares (por ejemplo, 4, 6, 8 discos…).

El sistema asegura que cada bloque tiene exactamente *dos copias en discos distintos*, y la distribución se gestiona automáticamente mediante el motor interno de balanceo de Btrfs.

==== Ventajas

- *Alta tolerancia a fallos*: el sistema puede sobrevivir a la *falla simultánea de múltiples discos*, siempre que no se pierdan ambas copias de un mismo bloque. Esto ofrece mayor resiliencia que RAID 1 en volúmenes grandes.
- *Rendimiento mejorado*: al distribuir los bloques entre múltiples dispositivos, RAID 10 permite *lecturas y escrituras paralelas*, mejorando el throughput global en comparación con RAID 1.
- *Rebalanceo automático y ampliación progresiva*: es posible añadir discos adicionales y redistribuir los datos sin interrupciones de servicio, lo que facilita la *escalabilidad horizontal del volumen*.
- *Integración total con las funciones de Btrfs*: como snapshots, compresión, subvolúmenes, y verificación de integridad, sin necesidad de capas de abstracción externas.

==== Limitaciones

- *Uso de espacio limitado al 50 %*: como en RAID 1, se almacena una copia de cada bloque en dos discos diferentes, por lo que solo la mitad del almacenamiento físico está disponible para datos útiles.
- *Requiere al menos cuatro discos*: es el mínimo técnico para que Btrfs distribuya adecuadamente los bloques espejados y pueda aplicar striping de forma efectiva.
- *Mayor complejidad de distribución interna*: aunque transparente para el usuario, la gestión de múltiples pares de bloques espejados puede implicar procesos de rebalanceo más costosos a medida que crece el volumen.

=== RAID 1C3 y RAID 1C4

*RAID 1C3* y *RAID 1C4* son extensiones recientes del esquema de replicación de Btrfs, introducidas para *aumentar el nivel de redundancia* más allá del clásico RAID 1. Estas configuraciones permiten crear *tres o cuatro copias de cada bloque de datos y metadatos*, respectivamente, distribuidas en diferentes dispositivos del volumen. Su nomenclatura sigue la convención `RAID 1C<n>`, donde *"C" significa "copies"*.

Estas variantes están disponibles en Btrfs desde las versiones más recientes del kernel Linux y herramientas asociadas (`btrfs-progs`), y representan una opción altamente resistente para datos críticos o sistemas donde se desea minimizar al máximo la posibilidad de pérdida de datos ante fallos múltiples de discos.

==== Principio de funcionamiento

En RAID 1C3, Btrfs mantiene *tres copias* de cada bloque en *tres discos distintos*. De forma análoga, RAID 1C4 genera *cuatro copias*. Esto implica una *redundancia superior* respecto al RAID 1 tradicional, que solo guarda dos copias, y permite *sobrevivir a la pérdida simultánea de hasta dos (en el caso de C3) o tres discos (en el caso de C4)*, siempre que no contengan todas las copias de un mismo bloque.

==== Ventajas

- *Tolerancia a fallos muy elevada*: RAID 1C3 permite que fallen hasta dos discos, y RAID 1C4 hasta tres, sin pérdida de datos, siempre que haya al menos una copia intacta de cada bloque.
- *Detección y corrección de errores más robusta*: combinando checksums con múltiples copias, Btrfs puede identificar y recuperar bloques corruptos con un alto grado de fiabilidad.
- *Configuración flexible y dinámica*: es posible migrar desde RAID 1 o Single a RAID 1C3/1C4 mediante balanceos, sin reformatear el volumen ni perder datos.
- *Ideal para datos críticos*: estas configuraciones son muy adecuadas para datasets de gran valor (por ejemplo, backups de backups, documentos legales, archivos personales irremplazables).

==== Limitaciones

- *Elevada penalización de espacio útil*: RAID 1C3 y 1C4 consumen un *tercio o una cuarta parte*, respectivamente, del almacenamiento físico total. Es decir, con tres discos de 10 TB, RAID 1C3 ofrecerá solo 10 TB útiles.
- *Requieren al menos tantos discos como copias*: mínimo tres discos para RAID 1C3 y cuatro para RAID 1C4. La utilidad práctica de estas configuraciones aumenta en volúmenes grandes.
- *Compatibilidad dependiente de versión*: estas modalidades requieren versiones recientes del kernel y de `btrfs-progs`, por lo que su uso en sistemas con soporte limitado o distribuciones conservadoras puede no estar disponible sin actualizaciones manuales.

=== Conclusiones

A partir del análisis técnico de las distintas configuraciones RAID soportadas por Btrfs, es posible establecer una estrategia fundamentada para el diseño inicial y la futura evolución del sistema de almacenamiento propuesto.

En primer lugar, la modalidad *Single* queda descartada de forma categórica, ya que *no proporciona ningún tipo de redundancia ni tolerancia a fallos*. Dado que uno de los objetivos fundamentales de este NAS es *preservar la integridad y disponibilidad de los datos personales frente a fallos físicos*, cualquier configuración que implique un único punto de fallo resulta inaceptable desde el punto de vista de la fiabilidad.

En el otro extremo, las configuraciones *RAID 1C3 y RAID 1C4*, aunque altamente resilientes y técnicamente viables, *quedan descartadas en este escenario doméstico* debido a su elevado consumo de espacio y su enfoque en contextos de criticidad extrema. En entornos como centros de datos, infraestructuras gubernamentales o archivos de alta sensibilidad podrían ser justificables; sin embargo, *la relación entre redundancia y coste las vuelve innecesarias para un sistema de uso doméstico con backups externos complementarios*.

Esto deja como opciones óptimas a *RAID 1* y *RAID 10*, ambas plenamente compatibles con Btrfs y adecuadas para un equilibrio entre fiabilidad, eficiencia y rendimiento. Dado que el sistema será implementado inicialmente con *dos discos duros enterprise-grade*, la única configuración viable en esta fase será *RAID 1*, lo que proporcionará duplicación completa de datos y capacidad de recuperación ante el fallo de uno de los discos.

No obstante, gracias a la flexibilidad del sistema de archivos Btrfs, se deja abierta la posibilidad de *evolucionar el volumen a una configuración RAID 10* mediante la adición de dos discos adicionales. Esta transición podrá realizarse de forma *progresiva, no destructiva y sin interrupciones del servicio*, lo que permite una escalabilidad natural del sistema en función de las futuras necesidades de almacenamiento.

En resumen, la arquitectura de almacenamiento se inicia con un enfoque conservador y seguro (RAID 1 sobre dos discos), y queda preparada para escalar en rendimiento y capacidad (RAID 10 sobre cuatro discos) sin comprometer la integridad ni la continuidad del servicio.

= Chasis

El *chasis* constituye el componente físico que alberga y organiza el conjunto del hardware de un sistema NAS, incluyendo discos duros, placa base, fuente de alimentación, ventiladores y cableado. Su elección no debe subestimarse, ya que influye directamente en aspectos críticos como *la refrigeración, la accesibilidad para mantenimiento, la capacidad de expansión, el nivel de ruido y la eficiencia térmica general del sistema*.

En entornos NAS DIY, el chasis no es un mero contenedor: es una parte activa de la arquitectura. Su diseño debe estar alineado con el número de discos a instalar —tanto en la configuración inicial como en la proyectada a futuro—, con el tipo de formato de placa base (por ejemplo, Mini-ITX, Micro-ATX) y con las necesidades de ventilación continua para preservar la vida útil de los componentes, en especial los discos duros mecánicos (HDD), que son sensibles al exceso de temperatura.

Además, existen *características funcionales clave* que deben tenerse en cuenta durante la elección del chasis, como la *posibilidad de realizar hot-swapping*, es decir, *extraer e insertar discos duros sin necesidad de apagar el sistema*, lo cual resulta especialmente útil en operaciones de mantenimiento, reemplazo por fallo o expansión del almacenamiento sin afectar la disponibilidad del servicio.

En esta sección se analizarán los *principales tipos de chasis adecuados para proyectos NAS*, sus ventajas y limitaciones, así como recomendaciones concretas según factores como *espacio disponible, nivel de ruido tolerable, escalabilidad esperada y eficiencia energética*.

== Número adecuado de bahías

La *cantidad de bahías para discos duros* es una de las decisiones de diseño más relevantes a la hora de seleccionar un chasis adecuado para un sistema NAS DIY. Esta elección condiciona no solo la *capacidad de almacenamiento presente*, sino también la *escalabilidad futura* del sistema. Es, por tanto, una variable estratégica que debe definirse antes de abordar la elección del chasis.

Dado que este proyecto NAS empleará configuraciones de *RAID 1 o RAID 10*, es necesario tener en cuenta que *la capacidad efectiva de almacenamiento será, aproximadamente, la mitad de la capacidad total instalada*, ya que la otra mitad estará destinada a la replicación de datos para garantizar la tolerancia a fallos.

En los apartados anteriores se ha justificado la elección de *discos duros enterprise-grade de 10 TB*, por tratarse del nivel de entrada más fiable y económicamente viable dentro del segmento profesional. A partir de esta base, se pueden proyectar distintos escenarios según el número de bahías disponibles:

- Con *6 bahías* y discos de 10 TB:
  $(6 times 10) / 2 = 30$ TB útiles.

- Con *8 bahías* y discos de 10 TB:
  $(6 times 10) / 2 = 30$ TB útiles.

Aunque una capacidad de 30 TB pueda parecer suficiente a corto plazo, una estimación más realista debe considerar la naturaleza compartida del NAS dentro de una *unidad familiar*, y su *uso prolongado en el tiempo*, posiblemente durante décadas. Dividiendo 30 TB entre varios miembros del hogar, la cuota efectiva por persona puede volverse limitada rápidamente, especialmente considerando el crecimiento exponencial de contenido digital (fotografías en alta resolución, vídeos en 4K o 8K, copias de seguridad completas de dispositivos, etc.).

Por este motivo, *apostar por un chasis con al menos 8 bahías* ofrece una *mejor proyección de futuro*, permitiendo ampliar la capacidad sin sustituir la infraestructura base. Esta elección se justifica también desde un punto de vista económico y logístico: como se analizará en las secciones siguientes, *la diferencia de precio entre cajas de 6 y 8 bahías no es significativamente elevada*, y el *volumen físico de las cajas de 8 bahías sigue siendo razonable* —similar al tamaño de una impresora doméstica.

Por tanto, desde una perspectiva de *sostenibilidad a largo plazo, escalabilidad y coste-beneficio*, se establece como criterio de diseño la elección de un chasis con *8 bahías de 3,5"*, como base estructural para el sistema NAS propuesto.

== Opciones de chasis para NAS

Se ha realizado una investigación exhaustiva sobre las distintas opciones disponibles de chasis con ocho bahías, centrando el análisis en aquellas más adecuadas para un entorno doméstico compacto. Se han descartado aquellas alternativas cuyo volumen resulta excesivo (como la #link("https://www.inter-tech.de/productdetails-58/NAS-8_EN.html", "Inter-Tech NAS-8")) o que presentan un formato vertical tipo torre, dado que el formato horizontal se adapta mejor a las restricciones de espacio y distribución previstas en este proyecto (como en el caso de la #link("https://www.silverstonetek.com/es/product/info/server-nas/DS380/", "SilverStone DS380")). A partir de estos criterios, se analizan a continuación las opciones más relevantes que cumplen con los requisitos de compacidad, funcionalidad y orientación a uso NAS.


#let width = 40%

=== #link("https://www.u-nas.com/xcart/cart.php?target=product&product_id=17640", "U-NAS NSC-810A")

#figure(
  image("./images/chassis-u-nas.jpg", width: width),
  caption: [ U-NAS NSC-810A ],
)

La *U-NAS NSC-810A* se presenta como una de las cajas más compactas del mercado con soporte para *ocho unidades de disco de 3,5"*, manteniendo un volumen total de apenas *17,07 litros*. Su diseño tipo cubo y su construcción íntegra en *aluminio* la convierten en una solución especialmente atractiva para quienes buscan *maximizar la densidad de almacenamiento* sin renunciar a una estética cuidada ni a una calidad estructural elevada. A pesar de su tamaño extremadamente reducido, incorpora un *backplane SAS/SATA* de serie que permite el *intercambio en caliente (hot-swap)* de los discos, facilitando tanto el mantenimiento como la escalabilidad del sistema.

Una de las principales fortalezas de esta caja es su *orientación claramente profesional*, aunque pensada para entornos domésticos exigentes. Detalles como la *ventilación optimizada* (incluye dos ventiladores silenciosos de 120 mm) o la *compatibilidad con placas base Mini-ITX y Micro-ATX* reflejan una atención especial a la eficiencia térmica y a la flexibilidad en el montaje. Asimismo, dispone de *espacio adicional para una unidad de 2,5"*, habitualmente destinada al sistema operativo.

El precio de la NSC-810A suele oscilar entre alrededor de los *190 €*, dependiendo de la configuración y del distribuidor, ya que generalmente se adquiere *directamente al fabricante*. Este coste incluye el backplane, pero no la fuente de alimentación, que debe adquirirse por separado y estar en formato *Flex ATX* (tipo 1U de servidor). Este último aspecto representa uno de sus principales compromisos: el uso de fuentes Flex implica *mayores exigencias en cuanto a eficiencia y ruido*, además de requerir *cables cortos y bien gestionados* para encajar adecuadamente en un interior muy compacto.

=== #link("https://www.jonsbo.com/en/products/N3.html", "Jonsbo N3 Black")

#figure(
  image("./images/jonsbo-n3-black.jpg", width: width),
  caption: [ Jonsbo N3 Black ],
)

La *Jonsbo N3 Black* destaca como una de las opciones más equilibradas y compactas disponibles para la construcción de un NAS casero de *ocho bahías*. Con un volumen aproximado de *18,2 litros*, ofrece una capacidad de almacenamiento considerable en un chasis sorprendentemente reducido, gracias a un diseño interno de *doble nivel* que optimiza al máximo el espacio disponible. A pesar de su tamaño, incorpora *ocho bandejas hot-swap de 3,5"* conectadas a través de un *backplane SATA integrado*, lo que permite una gestión eficiente y segura de los discos.

Está construida en *metal de alta calidad*, con una cubierta de *aluminio de 2 mm* que aporta robustez sin comprometer la estética. Su diseño es sobrio y moderno, adecuado tanto para entornos técnicos como domésticos. En términos de refrigeración, la caja incluye *dos ventiladores de 100 mm* situados estratégicamente detrás de las unidades de disco, garantizando un flujo de aire constante sobre los HDDs. Además, el panel frontal cuenta con *filtro antipolvo magnético* y *LEDs individuales de actividad* para cada bahía, aportando funcionalidad adicional sin sacrificar el minimalismo estético.

Uno de los aspectos a tener en cuenta es su *compatibilidad exclusiva con fuentes de alimentación SFX*, con una longitud máxima de *105 mm*. Esta limitación puede requerir una planificación cuidadosa a la hora de seleccionar la fuente adecuada. Asimismo, el espacio interno, aunque bien organizado, sigue siendo *limitado al emplear placas Mini-ITX*, lo que implica restricciones en la elección del hardware y exige una gestión de cables precisa.

Con un precio aproximado de *150 €*, la *Jonsbo N3 Black* ofrece una *excelente relación calidad/precio*, posicionándose como una opción ideal para quienes buscan un *NAS compacto, silencioso y visualmente discreto*. Es especialmente recomendable para usuarios que priorizan la *eficiencia espacial*, la *estética moderna* y la *funcionalidad hot-swap real*, sin necesidad de recurrir a chasis más grandes ni a soluciones de tipo rack. En conjunto, se trata de una caja muy valorada en la comunidad entusiasta por su *equilibrio entre tamaño, prestaciones y diseño*.

#pagebreak()

== Anális comparativo

#table(
  columns: (1fr, 1fr, 1fr),
  inset: 10pt,
  table.header(
    [*Característica*],
    [*Jonsbo N3 Black*],
    [*U-NAS NSC-810A*],
  ),
  "Formato", "Horizontal, tipo torre mini", "Cubo ultracompacto",
  "Volumen", "18,2 L", "17,07 L",
  "Precio", "160 €", "190-300 €",
  "Material de construcción", "Acero y aluminio", "Aluminio",
  "Bahías de 3,5\"", "8 (hot-swap)", "8 (hot-swap)",
  "Backplane incluido", "Sí, SATA", "Sí, SAS/SATA",
  "Bahía adicional", "No", "1 × 2,5\" interna",
  "Placas base compatibles", "Mini-ITX", "Mini-ITX y Micro-ATX",
  "Fuente de alimentación", "SFX (hasta 105 mm)", "Flex ATX (formato 1U)",
  "Ventiladores incluidos", "2 × 100 mm (tras los HDD)", "2 × 120 mm silenciosos",
  "Gestión térmica", "Buena, centrada en los discos", "Muy buena, optimizada para silencio",
  "LEDs de actividad por disco", "Sí", "No especificado",
  "Acceso frontal", "Panel magnético con filtro antipolvo", "Bandejas frontales con aspecto profesional",
  "Dificultad de montaje", "Moderada (espacio reducido, SFX)", "Alta (tolerancias estrechas, cableado justo)",
  "Disponibilidad", "Alta, en tiendas europeas", "Limitada, venta directa del fabricante",
  "Estética", "Sobria, moderna", "Profesional, similar a equipos QNAP",
  "Público objetivo", "Usuarios domésticos exigentes", "Entusiastas avanzados, miniaturización extrema",
)

== Conclusiones

Tras el análisis comparativo de distintas opciones de chasis compatibles con configuraciones NAS de 8 bahías, se ha decidido optar por el modelo *Jonsbo N3 Black* como solución definitiva para este proyecto. Si bien la elección en este caso admite un cierto componente subjetivo, la evaluación técnica y práctica inclina la balanza hacia esta opción por varios motivos fundados.

La alternativa principal considerada, la *U-NAS NSC-810A*, presenta un diseño extremadamente compacto, lo cual es ventajoso en términos de espacio ocupado. Sin embargo, esta compacidad *podría dificultar considerablemente el proceso de montaje y mantenimiento*, especialmente al instalar discos, gestionar el cableado o integrar ventiladores adicionales. A ello se suma el hecho de que *este modelo es difícil de adquirir a través de distribuidores europeos o nacionales*, lo que introduce incertidumbre logística y posibles problemas de garantía o sustitución de piezas.

En contraste, la *Jonsbo N3* ofrece un *diseño más espacioso*, lo cual —si bien implica un volumen algo mayor— *facilita el montaje interno*, mejora el flujo de aire y *no representa un inconveniente significativo en el contexto doméstico*. Además, en términos de percepción material, este chasis transmite *una mayor robustez y calidad de fabricación*, acompañada de una estética sobria y cuidada que puede resultar más adecuada para su integración en entornos no industriales.

El factor económico también resulta relevante: el precio de la U-NAS varía sustancialmente entre proveedores, desde *190 € en su página oficial (sin impuestos ni envío) hasta más de 340 € en plataformas como Aliexpress*, lo que introduce un grado de *inestabilidad comercial*. La Jonsbo N3, por el contrario, presenta *una mayor disponibilidad en el mercado europeo* y precios más consistentes.

En conjunto, estos factores justifican la elección de la *Jonsbo N3 Black* como chasis idóneo para este NAS DIY: *funcional, accesible, bien ventilado, razonablemente compacto y con capacidad para 8 bahías*, alineado con los objetivos de durabilidad, fiabilidad y escalabilidad del proyecto.

= Placa base y hardware principal

La selección de la *placa base y del hardware principal* es uno de los pilares técnicos fundamentales en el diseño de un sistema NAS DIY. Estos componentes definen no solo la *compatibilidad con el resto del hardware* (memoria, discos, fuente de alimentación, chasis), sino también aspectos clave como el *consumo energético, la capacidad de expansión, la eficiencia térmica, la estabilidad del sistema y el soporte a largo plazo*.

A diferencia de un entorno de escritorio o gaming, donde se priorizan el rendimiento bruto y la capacidad gráfica, un NAS requiere un hardware optimizado para *operación continua (24/7)*, con bajo consumo, buena gestión térmica y múltiples interfaces de conectividad orientadas al almacenamiento, como *SATA, PCIe, USB, Ethernet de alta velocidad y headers GPIO o UART* en placas ARM.

Esta sección analizará los criterios técnicos más relevantes para seleccionar una placa base adecuada, presentará una comparativa entre opciones actuales del mercado —tanto x86 como ARM— y concluirá con una propuesta de elección alineada con los objetivos de este proyecto: *eficiencia, escalabilidad, estabilidad y coste contenido*.

== Características a considerar

La elección de una *placa base* para un sistema NAS DIY debe responder a un conjunto específico de *criterios funcionales y técnicos*, distintos a los habituales en entornos de computación personal o estaciones de trabajo. En este contexto, la prioridad se desplaza desde la potencia de procesamiento hacia factores como *la estabilidad a largo plazo, el soporte para almacenamiento masivo, la eficiencia energética y la conectividad de red*.

A continuación, se detallan las principales características que deben ser consideradas:

=== Arquitectura y tipo de CPU

Uno de los aspectos clave es la arquitectura del procesador integrado o soportado por la placa base. Existen dos grandes opciones:

- *x86\_64 (AMD/Intel)*: arquitectura ampliamente compatible, con buen soporte para virtualización, pero con mayor consumo energético. Más habitual en placas base ATX/Mini-ITX estándar.
- *ARM (Rockchip RK3588, Raspberry Pi, etc.)*: ofrece una *excelente eficiencia energética*, bajo coste y formatos compactos, ideal para un NAS con bajo consumo 24/7. Sin embargo, puede tener limitaciones en cuanto a compatibilidad con algunas distros o drivers especializados.

=== Consumo energético y eficiencia térmica

La operación continua de un NAS exige un equilibrio entre potencia y consumo. Es preferible optar por soluciones de *bajo TDP (Thermal Design Power)* que permitan refrigeración pasiva o semipasiva, contribuyendo a reducir el ruido y el desgaste mecánico de los ventiladores.

=== Conectividad de almacenamiento

- *Número de puertos SATA*: Cuantos más puertos SATA nativos integre la placa base, mejor. Idealmente debe ofrecer soporte para el número total de discos planificados (en este caso, 8).
- *Soporte PCIe*: En placas con pocos puertos SATA nativos, disponer de *ranuras PCIe* permite instalar controladoras adicionales SATA o NVMe.
- *Compatibilidad con discos NVMe*: Aunque no esencial, contar con uno o más slots M.2 NVMe permite añadir almacenamiento rápido para cachés, bases de datos o contenedores.

=== Capacidad de expansión y RAM

La *memoria RAM* es un componente esencial en cualquier sistema NAS, ya que afecta directamente a la *capacidad del sistema para mantener múltiples servicios en ejecución simultánea*, gestionar cachés de disco, ejecutar contenedores, y procesar operaciones de compresión, verificación de integridad y snapshots, especialmente en sistemas de archivos avanzados como *Btrfs*.

Aunque el servidor no estará orientado a tareas computacionalmente intensivas —como renderizado, virtualización pesada o compilación—, sí se prevé que *mantenga en paralelo múltiples contenedores ligeros* (por ejemplo, servicios web, automatización, sincronización, streaming local o backup automatizado). En este escenario, la carga se distribuye más en *ancho de banda de memoria y concurrencia de procesos*, que en picos de uso de CPU.

Teniendo esto en cuenta, se estima que una configuración de entre *16 GB y 32 GB de RAM* será adecuada para sostener con comodidad la carga de trabajo proyectada. Si bien 16 GB pueden ser suficientes, optar directamente por *32 GB proporciona un margen de seguridad operativo*, permitiendo:

- Alojamiento de más contenedores sin degradación de rendimiento.
- Mayor uso de RAM para cacheo por parte del sistema de archivos.
- Ejecución de tareas administrativas (scrubbing, backups, sincronización) sin necesidad de swap.
- Posible uso futuro de servicios más intensivos, como bases de datos o servicios multimedia autogestionados.

Por tanto, y en consonancia con el principio de *sobredimensionar razonablemente la RAM* para sistemas en operación 24/7, se recomienda adoptar *32 GB de memoria DDR4* como punto de partida, siempre que la placa base elegida lo permita y el coste lo haga viable dentro del presupuesto general del proyecto.

=== Almacenamiento para el sistema operativo

En el diseño de un sistema NAS, es fundamental *separar el almacenamiento dedicado al sistema operativo y servicios base* del almacenamiento de largo plazo destinado a los datos del usuario. Esta separación no solo mejora la organización lógica y el rendimiento del sistema, sino que también *facilita las tareas de mantenimiento, backup, restauración y escalabilidad* futura.

Por esta razón, *no se recomienda utilizar los discos duros mecánicos (HDD) destinados al almacenamiento masivo de datos* para instalar el sistema operativo, contenedores o servicios auxiliares. Los discos HDD están optimizados para almacenar grandes volúmenes de información con baja rotación (archivos multimedia, documentos, backups), pero *no ofrecen el rendimiento necesario para operaciones frecuentes de lectura/escritura aleatoria*, como las que requieren el sistema y sus servicios en ejecución.

En su lugar, se recomienda utilizar una *unidad de estado sólido (SSD)* dedicada para el sistema operativo y las capas de servicios, preferiblemente conectada a través de *NVMe (M.2)* o *SATA* según la disponibilidad de puertos y la placa base seleccionada. Este enfoque permite:

- *Arranque rápido* y mejora en la capacidad de respuesta del sistema.
- *Ejecución fluida de múltiples contenedores o servicios simultáneos*, especialmente si requieren acceso frecuente al disco (bases de datos, cachés, servidores web).
- *Reducción del desgaste mecánico de los HDD*, al evitar escrituras innecesarias sobre ellos.

En cuanto a la capacidad necesaria, incluso en escenarios exigentes con múltiples servicios desplegados, una unidad SSD de *512 GB* es más que suficiente para alojar:

- El sistema operativo base (e.g., NixOS).
- Decenas de contenedores y sus volúmenes persistentes.
- Logs, herramientas de administración y monitorización.
- Espacio adicional para snapshots del sistema, actualizaciones o pruebas temporales.

En resumen, se recomienda *dedicar un SSD de al menos 512 GB exclusivamente para el sistema operativo y servicios del NAS*, dejando los discos mecánicos para su función principal: *almacenamiento de datos duradero, seguro y escalable*.

=== Conectividad de red

- Se recomienda al menos un puerto *Gigabit Ethernet (GbE)*. Idealmente, debe incluir *2.5 GbE o superior*, o al menos permitirlo vía expansión PCIe o USB.
- Algunas placas ARM modernas ya incluyen *2.5 GbE*, lo que las hace muy atractivas para un NAS moderno.

=== Soporte de software y comunidad

- La placa seleccionada debe tener *soporte maduro en el kernel de Linux* y documentación suficiente.
- Es especialmente importante verificar la compatibilidad con la distribución Linux elegida (como veremos más adelante, NixOS).
- Una comunidad activa y actualizaciones frecuentes del firmware o U-Boot/UEFI son factores clave para garantizar la sostenibilidad a largo plazo del sistema.

== Placas recomendadas

=== #link("https://es.aliexpress.com/i/1005008428781672.html", "Topton Intel N150/N100")

#figure(
  image("./images/board-topton-intel.jpg", width: width),
  caption: [ Topton Intel N100/N150  ],
)

Una de las opciones más atractivas dentro del ecosistema de placas base compactas y eficientes para NAS DIY es la serie *Topton N100/N150*, que integra procesadores Intel de la familia Alder Lake-N, lanzados específicamente para *entornos de bajo consumo energético* y *uso continuo*. Estas soluciones representan un equilibrio notable entre rendimiento, eficiencia y coste, posicionándose como una alternativa sólida para proyectos domésticos y semi-profesionales de almacenamiento en red.

==== Características generales

Ambas versiones de la placa —basadas en los SoC *Intel N100* y *N150*— comparten una arquitectura orientada a la eficiencia, con TDPs muy bajos (entre 6 W y 10 W) y una integración óptima de CPU, GPU y controladores periféricos. En términos de rendimiento, el *N150* presenta una ligera mejora respecto al N100, con una frecuencia de reloj superior y mayor rendimiento multihilo, aunque en escenarios NAS esta diferencia es *marginal y no determinante*.

==== Conectividad de almacenamiento

De forma nativa, la placa incluye *6 puertos SATA III*, lo que la hace adecuada para configuraciones con hasta seis discos duros. No obstante, como este proyecto contempla el uso de *8 bahías*, será necesario *ampliar la conectividad SATA*. Para ello, la placa incorpora *dos ranuras M.2*, una de las cuales puede utilizarse para instalar una unidad SSD NVMe (destinada al sistema operativo), y la otra para un *adaptador PCIe a doble puerto SATA*. Estas tarjetas de expansión son ampliamente compatibles y económicas (alrededor de *7 €*), y permiten escalar la placa hasta las 8 unidades requeridas.

==== Configuración y coste estimado

Las versiones con *32 GB de RAM y 1 TB de almacenamiento NVMe* ofrecen una solución lista para montar el NAS con muy pocos componentes adicionales. El coste total estimado, incluyendo el adaptador de expansión SATA, es el siguiente:

#table(
  columns: (1fr, 1fr, 1fr),
  inset: 10pt,
  table.header(
    [*Modelo*], [*Topton N100*], [*Topton N150*]
  ),
  table.cell([*RAM*]), "32 GB DDR5", "32 GB DDR5",
  table.cell([*NVMe*]), "1 TB NVMe", "1 TB NVMe",
  table.cell([*Expansión SATA*]), "2xSATA PCIe", "2xSATA PCIe",
  table.cell([*Precio total*]), table.cell([*307,39 €*]), table.cell([*317,39 €*]),
)

=== #link("https://es.aliexpress.com/i/1005007001368624.html", "Topton N355")

#figure(
  image("./images/board-topton-n355.jpg", width: width),
  caption: [Topton N355 ],
)

La *Topton N355* representa una evolución dentro de la misma línea de placas compactas y eficientes de bajo consumo analizadas previamente (N100/N150), integrando el procesador *Intel i3-N355*, un *SoC de 8 núcleos* basado en la arquitectura *Twin Lake-N*. Este procesador supone un escalón superior respecto al N150 tanto en capacidad de cómputo como en rendimiento multihilo, manteniendo al mismo tiempo un consumo energético contenido (TDP en torno a 15 W), comparable al de soluciones ARM como el RK3588.

=== Características técnicas

La configuración base de esta placa incluye:

- *6 puertos SATA III nativos*, suficientes para una configuración media, pero insuficientes para alcanzar las 8 bahías requeridas. Al igual que en modelos anteriores, esto se puede solventar fácilmente utilizando un *adaptador M.2 PCIe a 2×SATA*, dado que la placa incluye *dos ranuras M.2*.
- *32 GB de memoria RAM DDR4* no soldada, lo que permite su sustitución o ampliación futura.
- *1 TB de almacenamiento NVMe*, adecuado para alojar el sistema operativo y todos los servicios auxiliares.
- Soporte completo en Linux para todos los componentes, incluyendo gráficos integrados y funciones de ahorro de energía, gracias al amplio soporte de Intel en el kernel.

=== Coste estimado

La placa, en su versión equipada con *32 GB de RAM y 1 TB NVMe*, se encuentra actualmente en el mercado (AliExpress) a un precio de referencia de *404,99 €*, a los que se debe sumar el coste del adaptador M.2 a SATA (aproximadamente 7 €), por lo que el coste total estimado sería de *411,99 €*.

=== #link("https://es.aliexpress.com/item/1005006953997214.html?gatewayAdapt=glo2esp", "Topton N13 Q670 Plus")

#figure(
  image("./images/board-topton-n13.jpg", width: width),
  caption: [ N13 Q670 Plus  ],
)

La placa *Topton N13 Q670 Plus* se presenta como una alternativa interesante dentro del ecosistema x86, especialmente por su *soporte nativo de hasta 8 discos duros SATA* a través de conectores *Mini SAS*, lo cual la posiciona como una candidata natural para configuraciones NAS con múltiples bahías sin necesidad de tarjetas de expansión adicionales.

Desde un punto de vista técnico, esta placa base ofrece:

- Compatibilidad con procesadores Intel de 12ª y 13ª generación (socket LGA1700).
- Interfaces de alto rendimiento como PCIe 4.0, múltiples puertos M.2 y USB 3.x.
- *Capacidad de expansión SATA a gran escala* sin depender de adaptadores externos, lo que se traduce en menor complejidad en el cableado interno y mayor fiabilidad.

Sin embargo, su principal inconveniente es el *coste elevado*. A fecha de redacción de este documento, el precio estimado asciende a *463,39 €*, únicamente por la placa base. A esta cifra habría que añadir el coste de:

- Un procesador compatible (mínimo 100 €).
- Módulos de memoria RAM (aproximadamente 60–100 € por 16–32 GB).
- Unidad SSD NVMe o SATA para el sistema operativo (20–40 €).

Esto eleva el *coste total de esta opción muy por encima de los 600 €*, lo cual *supera considerablemente el presupuesto proyectado para el sistema NAS DIY* en este estudio, especialmente considerando que otras alternativas ofrecen prestaciones equivalentes a una fracción del coste.

=== #link("https://es.aliexpress.com/item/1005008487844731.html", "Radxa ROCK 5 ITX+, CPU RK3588")

#figure(
  image("./images/board-radxa-rock-5.jpg", width: width),
  caption: [ Radxa ROCK 5 ITX+  ],
)

La *Radxa ROCK 5 ITX+* se posiciona como una opción altamente eficiente dentro del segmento ARM para sistemas NAS DIY. Esta placa, basada en una arquitectura *ARM de cuatro núcleos*, está diseñada con un enfoque explícito en *bajo consumo energético*, manteniendo un rendimiento suficiente para gestionar múltiples servicios en paralelo sin necesidad de ventilación activa ni refrigeración avanzada.

==== Características técnicas destacadas

Uno de los elementos más distintivos de esta placa que su CPU, el RK3588, incluye una *Unidad de Procesamiento Neuronal (NPU)* integrada. Esta NPU ofrece capacidades específicas para acelerar *cargas de trabajo basadas en inteligencia artificial*, lo que abre la puerta a funcionalidades avanzadas dentro del entorno NAS, como el *etiquetado automatizado de imágenes* o el reconocimiento facial en álbumes fotográficos mediante servicios como *Immich o Photoprism*.

Además, la ROCK 5 ITX+ incorpora *soporte para decodificación de vídeo por hardware*, alcanzando resoluciones de hasta *8K a 60 fps*, lo que la convierte en una candidata ideal para aplicaciones de *transcodificación multimedia en tiempo real*, como servidores *Jellyfin o Plex*, sin necesidad de una GPU dedicada.

==== Compatibilidad con Linux

Una consideración fundamental al trabajar con placas ARM es la disponibilidad de *soporte oficial en el kernel de Linux*, ya que muchas placas dependen de parches o kernels específicos. En este caso, se ha verificado la presencia de los archivos *Device Tree Source (DTS)* correspondientes en el *mainline del kernel de Linux*, lo que garantiza *soporte oficial, actualizaciones de seguridad y compatibilidad con distribuciones como NixOS*, base del sistema propuesto en este estudio.

==== Expansión y almacenamiento

La placa se comercializa en dos variantes: una con 4 puertos SATA integrados, y otra que sustituye estos por *dos ranuras M.2* con interfaz PCIe 3.0 x2. Dado que ninguna de las versiones incluye soporte nativo para 8 unidades SATA, se opta por la *versión con doble M.2*, lo que permite mayor flexibilidad:

- Un *SSD NVMe* se utilizará para alojar el sistema operativo y los servicios.
- El segundo puerto M.2 se empleará para conectar una *tarjeta adaptadora de expansión* que permita controlar hasta 8 unidades SATA mediante *Mini-SAS*.

La capacidad de cada ranura M.2 está limitada a *PCIe 3.0 x2*, lo cual debe tenerse en cuenta para seleccionar componentes que no excedan ese ancho de banda.

==== Configuración y coste estimado

La configuración propuesta es la siguiente:

#table(
  columns: (auto, 1fr),
  inset: 10pt,
  table.header(
    [*Componente*], [*Precio estimado*]
  ),
  "Radxa ROCK 5 ITX+ (con 32 GB de RAM)", "300,99 €",
  "SSD NVMe PCIe 3.0 x2 (Gigabyte 512 GB)", "71,21 €",
  "Tarjeta M.2 PCIe → 8×SATA (KALEA Informatique)", "65,00 €",
  table.cell([*Total*]), table.cell([*437,20 €*]),
)


Para contar con una referencia más precisa en términos de presupuesto, se puede considerar el uso de un *SSD de 1 TB*, como el *Samsung 980 NVMe*. Esta elección elevaría el coste total estimado a *452,98 €*, lo cual sigue siendo competitivo en comparación con soluciones x86 de características equivalentes.

=== #link("https://es.aliexpress.com/item/1005009254021608.html", "CWWK M8 i3-N355 8-bay")

#figure(
  image("./images/board-kingnovy-n355.jpg", width: width),
  caption: [ CWWK M8 i3-N355 8-bay  ],
)

Una de las opciones más completas y versátiles disponibles en el mercado para la construcción de un NAS doméstico avanzado es la placa base *Kingnovy i3-N355 8-bay*. Este modelo integra un conjunto equilibrado de características técnicas, alto rendimiento en procesamiento, conectividad avanzada y una amplia capacidad de expansión de almacenamiento. Su factor de forma Mini-ITX (17 × 17 cm) permite una integración sencilla en chasis compactos como la Jonsbo N3, manteniendo al mismo tiempo una gran funcionalidad.

=== Características destacadas

La placa está diseñada para admitir múltiples procesadores de la gama Intel Alder Lake-N y Twin Lake, incluyendo modelos como el *N100, N150, i3-N305 y i3-N355*. En el caso concreto de esta implementación, se ha optado por el *Intel i3-N355*, un procesador de *8 núcleos de arquitectura eficiente*, lo cual resulta altamente adecuado para entornos multitarea y la ejecución simultánea de múltiples contenedores o servicios dentro del NAS.

Entre sus características más relevantes destacan:

- *Soporte de hasta 48 GB de memoria DDR5 SO-DIMM* a 4800 MHz, en una única ranura.
- *Dos puertos M.2 NVMe PCIe 3.0 x1* (formato 2280), útiles tanto para almacenamiento rápido como para tarjetas de expansión SATA o de red.
- *Ocho puertos SATA 3.0*, habilitados a través de dos conectores Mini SAS (SFF-8643), permitiendo una gestión directa y ordenada de hasta 8 discos duros de forma nativa.
- *Conectividad de red de alto rendimiento*, con:
  - Un puerto *10 GbE (Marvell AQC113C)*,
  - Dos puertos *2.5 GbE (Intel i226-V)*.
- *Salidas de vídeo HDMI 2.0 y DisplayPort 1.4*, ambas compatibles con 4K a 60 Hz.
- *Numerosos puertos USB*, incluyendo:
  - USB 3.2 Gen1 tipo A,
  - USB tipo C (10 Gbps),
  - Conectores internos USB 2.0, 3.0 y tipo E.
- *Soporte para Wi-Fi mediante conector M.2 E-Key*, compatible con módulos como Intel AX210.
- *Compatibilidad con sistemas Linux y NAS open source* (TrueNAS, OpenMediaVault, NixOS, entre otros), siempre en modo EFI.

Adicionalmente, la placa base está fabricada sobre un *PCB de seis capas con condensadores sólidos*, lo que mejora la durabilidad y reduce la susceptibilidad a la humedad. El diseño interno está pensado para garantizar estabilidad operativa a largo plazo, incluso en escenarios de carga continua como los propios de un NAS doméstico 24/7.

=== Coste estimado

Para facilitar una comparación coherente con las demás placas analizadas previamente, se ha optado por considerar la configuración compuesta por *32 GB de memoria RAM DDR5* y *1 TB de almacenamiento SSD NVMe*, equivalente a la utilizada en las otras opciones. En este caso, dicha configuración tiene un coste aproximado de *402,99 €*, según su disponibilidad actual en la plataforma AliExpress. Dada la relación entre prestaciones y precio, así como la integración de funcionalidades avanzadas como red 10 GbE, soporte nativo para 8 discos y arquitectura eficiente, esta placa se perfila como una *alternativa sólida y competitiva dentro del ecosistema NAS DIY*.


=== #link("https://www.amazon.es/MNBOXCONET-Motherboard-Mainboard-6%C3%97SATA3-0-Computer/dp/B0F137WZ11?th=1", "MNBOXCONET N100/N150/N305/N355 NAS")

#figure(
  image("./images/board-mnboxconet-n150.jpg", width: width),
  caption: [ MNBOXCONET N100/N150/N305/N355 NAS  ],
)

La placa *MNBOXCONET NAS Series* representa una de las opciones *más versátiles y personalizables* analizadas en el presente estudio. Su diseño permite seleccionar entre *varios procesadores Intel de bajo consumo* de la familia Alder Lake-N (N100, N150, N305 y N355), lo que otorga al usuario una *gran capacidad de adaptación* entre eficiencia energética y rendimiento, según las necesidades de carga de trabajo y presupuesto.

=== Características destacadas

Este modelo se comercializa en múltiples configuraciones de CPU, memoria RAM y almacenamiento SSD. A diferencia de otras placas integradas como la Topton, la MNBOXCONET *no incluye la RAM soldada*, lo cual *permite actualizar o reemplazar la memoria en el futuro*, aportando mayor flexibilidad y longevidad al sistema.

En términos de almacenamiento, incluye de forma nativa *6 puertos SATA III*, lo que implica que, al igual que en otras placas previamente analizadas, *es necesario incorporar un adaptador PCIe adicional para alcanzar las 8 bahías requeridas*. Afortunadamente, la placa integra *dos ranuras M.2*, lo que permite:

- Instalar un *SSD NVMe* dedicado al sistema operativo y servicios.
- Utilizar un *adaptador M.2 PCIe a SATA* (7 €) para añadir los dos puertos SATA restantes.

Esta arquitectura modular permite escalar el sistema con facilidad sin comprometer su eficiencia ni aumentar significativamente el coste.

=== Coste estimado por configuración

A continuación, se muestra la estimación de precio para las diferentes variantes de procesador, incluyendo *32 GB de RAM, 1 TB de SSD NVMe* y el *adaptador M.2 a SATA*:

#table(
  columns: (auto, auto),
  inset: 10pt,
  table.header(
    [*Modelo*], [*Precio estimado*]
  ),
  "MNBOXCONET N100, 32 GB DDR5, 1 TB NVMe + expansión SATA", "420,98 €",
  "MNBOXCONET N150, 32 GB DDR5, 1 TB NVMe + expansión SATA", "436,99 €",
  "MNBOXCONET N305, 32 GB DDR5, 1 TB NVMe + expansión SATA", "482,86 €",
  "MNBOXCONET N355, 32 GB DDR5, 1 TB NVMe + expansión SATA", "566,89 €",
)

== Análisis comparativo

Una vez evaluadas todas las placas candidatas en términos de características técnicas, compatibilidad, consumo energético y capacidad de expansión, podemos afirmar que *todas ellas cumplen con los requisitos funcionales básicos del sistema NAS propuesto*. No obstante, para tomar una decisión informada y alineada con los principios de sostenibilidad y eficiencia del proyecto, es fundamental incorporar un *análisis comparativo de coste total*.

A continuación se presenta una tabla resumen con el coste estimado de cada configuración, que incluye *32 GB de RAM, un SSD NVMe de 1 TB*, y, en los casos que lo requieren, *un adaptador M.2 a 2×SATA*:

#table(
  columns: (auto, auto),
  inset: 10pt,
  table.header(
    [*Modelo*], [*Precio estimado*]
  ),
  "Topton N100, 32 GB DDR5, 1 TB NVMe + expansión SATA", "307,39 €",
  "Topton N150, 32 GB DDR5, 1 TB NVMe + expansión SATA", "317,39 €",
  "CWWK M8 i3-N355 8-bay, 32 GB DDR5, 1 TB NVMe", "402,99 €",
  "Topton N355, 32 GB DDR5, 1 TB NVMe + expansión SATA", "411,99 €",
  "Radxa ROCK 5 ITX+, 1 TB NVMe + expansión SATA", "452,98 €",
  "MNBOXCONET N100, 32 GB DDR5, 1 TB NVMe + expansión SATA", "420,98 €",
  "MNBOXCONET N150, 32 GB DDR5, 1 TB NVMe + expansión SATA", "436,99 €",
  "MNBOXCONET N305, 32 GB DDR5, 1 TB NVMe + expansión SATA", "482,86 €",
  "MNBOXCONET N355, 32 GB DDR5, 1 TB NVMe + expansión SATA", "566,89 €",
)

== Conclusiones

Tras el análisis comparativo realizado, la *CWWK M8 con procesador Intel i3-N355* se consolida como la opción más adecuada para la implementación del sistema NAS DIY propuesto en esta tesis. Esta placa base destaca por su *compatibilidad nativa con hasta 8 bahías SATA*, lo que elimina la necesidad de expansores adicionales y simplifica el montaje del sistema. Además, presenta un *coste total inferior al de alternativas similares* como la Topton N355, manteniendo unas prestaciones equivalentes o incluso superiores en aspectos clave.

El procesador *Intel i3-N355*, basado en la arquitectura _Twin Lake-N_, incorpora *8 núcleos de bajo consumo energético*, lo que lo convierte en una solución óptima para escenarios en los que se requiere ejecutar múltiples servicios en paralelo (por ejemplo, contenedores Docker o Podman, tareas de backup, servidores multimedia o servicios de monitoreo). Esta capacidad de paralelización resulta fundamental para garantizar un rendimiento sostenido sin comprometer la eficiencia energética del sistema.

En contraste, opciones basadas en arquitecturas ARM, como la *Radxa ROCK 5 ITX+*, aunque atractivas por su eficiencia energética y prestaciones como *NPU integrada* o *decodificación de vídeo 8K por hardware*, presentan _limitaciones críticas_ que comprometen su idoneidad en entornos de producción:

- *Compatibilidad limitada con distribuciones Linux generalistas*, con necesidad de kernels específicos o personalización de imágenes.
- *Disponibilidad restringida de contenedores Docker estándar*, al requerir versiones específicas para ARM, lo cual complica la gestión y mantenibilidad a medio y largo plazo.
- *Menor madurez del ecosistema de drivers y soporte periférico*, lo que puede derivar en incidencias difíciles de depurar en entornos no estándar.

Aunque la ausencia de una NPU en la CWWK M8 puede suponer una ligera desventaja para tareas como el etiquetado automático de imágenes, este tipo de procesos puede ser _reprogramado para ejecutarse en segundo plano o durante horas valle_, empleando la CPU x86 sin que ello represente una penalización significativa en el rendimiento global del sistema.

En definitiva, la elección de la *CWWK M8 i3-N355* representa la solución que mejor equilibra *rendimiento, eficiencia energética, escalabilidad, compatibilidad software y coste económico*, lo que la posiciona como la base ideal sobre la cual construir un sistema NAS doméstico de altas prestaciones, bajo consumo y amplia proyección a futuro.

= Disipador

La elección del disipador es un aspecto relevante en la construcción de un NAS doméstico, especialmente si se prioriza un funcionamiento silencioso y eficiente dentro de un espacio reducido.

Dado que el sistema está basado en un procesador *Intel i3-N355*, orientado al bajo consumo energético (con un *TDP de 15 W*), *no se requiere un sistema de refrigeración de alto rendimiento*, pero *tampoco sería adecuado optar por una solución completamente pasiva*, ya que durante cargas prolongadas de trabajo (por ejemplo, tareas de copia de seguridad, resincronización RAID) podría alcanzarse una temperatura operativa elevada.

Se recomienda, por tanto, un *disipador de bajo perfil*, que facilite la instalación en chasis compactos como la *Jonsbo N3*, y que ofrezca *un equilibrio adecuado entre rendimiento térmico y nivel sonoro*. Una solución con *ventilador de tamaño moderado (80–92 mm)*, control PWM y nivel de ruido por debajo de los *20–25 dB* sería ideal. Además, el uso de *pasta térmica de calidad* puede mejorar la transferencia de calor y reducir la necesidad de ciclos de ventilación intensivos.

En resumen, el disipador debe cumplir los siguientes requisitos:

- *Altura reducida* (compatibilidad con cajas SFF como la Jonsbo N3).
- *Bajo nivel sonoro* para no comprometer el confort acústico.
- *Capacidad de refrigeración suficiente* para un TDP ≤ 15 W.
- *Montaje sencillo y alta compatibilidad* con zócalos Intel.

Un aspecto importante a tener en cuenta en la selección del disipador es la *compatibilidad con el sistema de montaje de la placa base*. En el caso concreto de la *placa Topton N355*, la *distancia entre los orificios de fijación del disipador* es de *75 mm × 75 mm*. Por tanto, resulta imprescindible *verificar que el disipador seleccionado sea compatible con este patrón de montaje*, a fin de garantizar una instalación segura y una presión adecuada sobre la superficie del procesador.

== Opciones recomendadas

=== #link("https://es.aliexpress.com/i/1005006301753930.html", "Jonsbo HP-400S/PMT 4")

El *Jonsbo HP-400S PMT* se presenta como una solución de refrigeración *compacta, silenciosa y altamente eficiente*, ideal para sistemas ITX como el propuesto en este proyecto NAS.

Este modelo incorpora *cuatro heat pipes de alto rendimiento* que permiten una *disipación térmica eficaz*, incluso en escenarios de carga sostenida. Su diseño de *perfil bajo* garantiza la compatibilidad con chasis compactos como la *Jonsbo N3*, manteniendo una estética sobria y profesional.

Además, cuenta con un *ventilador PWM de 4 pines*, lo que permite un *control dinámico de la velocidad en función de la temperatura del procesador*, reduciendo así el ruido en condiciones de baja carga. Esta característica es especialmente importante en entornos domésticos donde se prioriza el silencio operativo.

Cabe destacar que este disipador es #link("https://www.toptonpc.com/product/12th-gen-intel-i3-n305-n100-nas-motherboard-6-bay-4x-i226-v-2-5g-2nvme-6sata3-0-ddr5-pciex1-type-c-mini-itx-router-mainboard/", "uno de los recomendados oficialmente por el fabricante Topton") para placa escogida en este documento, lo que respalda su *compatibilidad y fiabilidad* en este tipo de configuraciones.

En resumen, el Jonsbo HP-400S PMT combina:

- Excelente rendimiento térmico para CPUs de bajo TDP.
- Diseño de bajo perfil compatible con cajas compactas.
- Control preciso de velocidad mediante PWM.
- Instalación sencilla y compatibilidad asegurada.

= Fuente de alimentación

El diseño de un sistema NAS eficiente y estable no puede prescindir de una *fuente de alimentación adecuada*, ya que de ella depende no solo el funcionamiento continuo del sistema, sino también su fiabilidad a largo plazo. La elección de la fuente debe basarse en una estimación realista del *consumo energético pico*, incluyendo todos los componentes y teniendo en cuenta los momentos críticos como el *arranque simultáneo de los discos duros*, donde se concentra la mayor demanda energética del sistema.

== Estimación de consumo

Se parte de una configuración compuesta por los siguientes elementos:

*8 discos duros Seagate Exos X10* de 10 TB, que consumen, según ficha técnica del fabricante:

- *5 W en reposo*
- *8,4 W en operación activa*
- *Hasta 2,0 A a 12 V en pico de arranque*, es decir, *24 W por unidad al arrancar*.

El pico de arranque de los discos es el valor más restrictivo, ya que ocurre simultáneamente durante el encendido. Por tanto:

*Consumo pico de los 8 discos duros al arrancar:*
8 × 24 W = *192 W*

A esto se suma el consumo del resto del sistema:

#table(
  columns: (auto, auto),
  inset: 10pt,
  table.header(
    [*Componente*], [*Consumo estimado*]
  ),
  "CPU Intel i3-N355", "15 W",
  "Placa base (controladores, bus, etc.)", "8 W",
  "Memoria RAM (1x32 GB DDR5)", "4 W",
  "SSD NVMe", "7 W",
  "Ventiladores + disipadores", "6 W",
  table.cell([*Subtotal (sin discos)*]), table.cell([*40 W*]),
)

*Consumo total estimado en pico:*
192 W (discos) + 40 W (resto del sistema) = *232 W*

== Recomendación de potencia de la fuente

Por motivos de seguridad, eficiencia y longevidad, se recomienda que la fuente de alimentación *no trabaje de forma continua por encima del 70–80 % de su capacidad nominal*. Además, debe ser capaz de suministrar los *picos de corriente* breves pero intensos durante el arranque de los discos.

Aplicando un _margen conservador del 25–30 %_ sobre el consumo pico estimado, el sistema debería estar respaldado por una fuente de alimentación capaz de suministrar _al menos 300 W reales_. Sin embargo, teniendo en cuenta que la caja seleccionada, la *Jonsbo N3*, únicamente admite fuentes de alimentación *formato SFX* con una longitud máxima de *105 mm*, la elección queda restringida a modelos compactos. Por tanto, se recomienda una *fuente SFX de entre 350 W y 400 W*, con *certificación 80 PLUS Bronze o superior*, que garantice tanto eficiencia energética como fiabilidad a largo plazo, manteniendo un margen seguro ante picos de consumo y futuras ampliaciones del sistema.

== Conclusión

Una fuente de alimentación de *350–400 W bien dimensionada* y con protecciones eléctricas adecuadas garantizará el funcionamiento estable del sistema NAS tanto en condiciones normales como en momentos críticos como el arranque. Esta elección no solo cubre las necesidades energéticas actuales, sino que permite cierta *holgura para la adición de nuevos discos o periféricos en el futuro* sin comprometer la eficiencia energética del sistema.

== Opciones recomendadas

=== #link("https://www.pccomponentes.com/corsair-sf450-450w-sfx-80-plus-platinum-full-modular", "Corsair SF450 450W SFX 80 Plus Platinum Full Modular")

#figure(
  image("./images/psu-corsair-sf450.jpg", width: width),
  caption: [ Corsair SF450 450W SFX 80 Plus Platinum Full Modular  ],
)

Entre las fuentes de alimentación compatibles con la caja *Jonsbo N3*, destaca la *Corsair SF450*, una fuente *SFX de 450 W* con *certificación 80 PLUS Platinum* y diseño *completamente modular*.

Esta fuente cumple sobradamente con los requisitos energéticos estimados para el sistema NAS, proporcionando *hasta 450 W*, lo que ofrece un amplio margen de seguridad frente al consumo pico calculado (#sym.tilde.op 234 W). Esta holgura permite afrontar con tranquilidad no solo las demandas del arranque simultáneo de los discos, sino también posibles *ampliaciones futuras de hardware* (discos adicionales, tarjetas de red, etc.).

La *certificación 80 PLUS Platinum* garantiza una *eficiencia energética superior al 90 % en la mayoría de escenarios de carga*, lo que se traduce en *menor generación de calor*, *menor consumo eléctrico a largo plazo* y *mayor durabilidad de los componentes* internos de la fuente y del sistema en general.

El hecho de que sea *modular* implica que todos los cables son desmontables, permitiendo conectar únicamente aquellos que se necesiten. Esto resulta especialmente útil en cajas compactas como la Jonsbo N3, ya que *reduce el desorden interno*, *mejora el flujo de aire* y *facilita el montaje y mantenimiento* del sistema.

En resumen, la *Corsair SF450* se presenta como una opción *óptima y robusta* para el proyecto, ofreciendo fiabilidad, eficiencia y compatibilidad estructural en un formato compacto ideal para el chasis elegido.

= Sistema de Alimentación Ininterrumpida (SAI)

El *Sistema de Alimentación Ininterrumpida (SAI)* constituye un componente esencial en cualquier configuración NAS que pretenda garantizar la *integridad de los datos* y la *continuidad del servicio*, incluso ante situaciones adversas del suministro eléctrico. Su función principal es actuar como *barrera de protección* frente a cortes de energía, subidas de tensión, fluctuaciones de voltaje y otras anomalías de la red eléctrica que podrían comprometer tanto el hardware como los datos almacenados.

Más allá de proporcionar *autonomía temporal* durante una interrupción eléctrica —normalmente en el orden de varios minutos—, lo más relevante en un contexto como este es su capacidad de *interactuar de forma inteligente con el sistema operativo del NAS* para permitir un *apagado controlado y seguro* del sistema.

== Requisitos funcionales mínimos

Para este proyecto, se identifican las siguientes características como imprescindibles en el SAI a seleccionar:

- *Capacidad de protección frente a sobretensiones* y cortes breves de corriente.
- *Autonomía mínima suficiente* para mantener el sistema operativo activo durante varios minutos (5–10 min), tiempo suficiente para ejecutar rutinas de apagado.
- *Interfaz de comunicación USB*, que permita al NAS *detectar automáticamente una caída de tensión* y ejecutar un *apagado ordenado (graceful shutdown)* mediante software.
- *Compatibilidad con software de monitorización* como *NUT (Network UPS Tools)*, ampliamente usado en sistemas UNIX/Linux, incluyendo distribuciones como NixOS.

== Ventajas funcionales

Un SAI correctamente integrado en la arquitectura del sistema cumple varias funciones críticas:

- *Evita la corrupción de datos* que puede producirse si los discos son desconectados repentinamente durante una escritura.
- *Protege la integridad del sistema de ficheros*, especialmente en configuraciones como BTRFS o ZFS, que pueden verse afectadas por cierres inesperados si no se sincronizan los metadatos correctamente.
- *Prolonga la vida útil del hardware*, evitando que se produzcan picos de corriente o ciclos de encendido/apagado incontrolados.
- *Permite programar notificaciones* o alertas ante eventos de fallo eléctrico, incluso mediante integración con servicios como Telegram o correo electrónico.

En suma, el SAI actúa como un *seguro energético y de integridad lógica* para el sistema, asegurando tanto la protección física del equipo como la consistencia de los datos.

== Estimación de Voltios-Amperios (VA) y potencia necesaria

Para seleccionar adecuadamente un Sistema de Alimentación Ininterrumpida (SAI), es imprescindible realizar una estimación precisa del consumo total del sistema y traducirlo a las unidades utilizadas habitualmente en estos dispositivos: *Voltios-Amperios (VA)*. Además, debe garantizarse una *autonomía mínima suficiente* que permita llevar a cabo un apagado controlado del sistema en caso de interrupción eléctrica.

=== Estimación de consumo total

El sistema NAS propuesto consta de:

- *8 discos duros* Seagate Exos X10 de 10 TB, con un consumo aproximado de *8 W por unidad en operación sostenida*, lo que da un total de *64 W*.
- *Placa base, CPU, RAM y SSD*, con un consumo estimado total de aproximadamente *40 W*, como se ha calculado en secciones anteriores.

Por tanto, el *consumo total en funcionamiento estable* es:

$ 64 "W" + 40 "W" = #math.bold("104W") $

=== Requisito de autonomía

Durante una interrupción eléctrica, el sistema debe permanecer encendido el tiempo suficiente para:

- Finalizar cualquier operación de escritura en disco.
- Detener adecuadamente los contenedores.
- Apagar servicios y desmontar sistemas de archivos de forma segura.

El sistema operativo y los servicios podrían requerir un máximo de *2 a 3 minutos* para este proceso. Para cubrir esta necesidad con holgura, se establece como objetivo una *autonomía de al menos 15 minutos*, lo que permite margen adicional para notificaciones o retardo programado de apagado.

=== Cálculo de energía en Wh

Para calcular la energía necesaria para mantener el sistema operativo durante el tiempo deseado:

$ "Energía necesaria (Wh)" = "Potencia (W)" times "Tiempo (h)" = 104 times 0,25 = 26 "Wh" $

Dado que los SAI presentan pérdidas internas (por disipación térmica, conversión AC/DC, etc.), se aplica un *margen de seguridad del 20 %*:


$ "Energía corregida" = 26 / (0,8) = 32,5 "Wh" $

=== Conversión a Voltios-Amperios (VA)

Los SAI suelen especificar su capacidad en VA, que depende del *factor de potencia (Power Factor, PF)*. Este factor refleja la eficiencia en la conversión de energía activa (W) respecto a la energía aparente (VA):

- *SAI básico:* PF ≈ 0,6
- *SAI de gama media/alta:* PF ≈ 0,8–0,9

Con esta información, se calcula la potencia aparente requerida:

- Con PF = 0,6 = $104/(0,6)≈173 "VA"$
- Con PF = 0,8 = $104/(0,8)≈130 "VA"$
- Con PF = 0,9 = $104/(0,9)≈115,6 "VA"$

== Conclusiones

A partir de estos datos, se concluye que un SAI con *una potencia nominal de al menos 200 VA* y *autonomía mínima de 15 minutos* cubriría de forma segura y conservadora las necesidades energéticas del sistema. Se recomienda optar por un modelo *con factor de potencia elevado (≥0,8)* y con soporte para *interfaz USB compatible con software de apagado programado*, como se detalló en el apartado anterior.

== Opciones recomendadas

=== #link("https://www.pccomponentes.com/salicru-sps-one-700va-360w", "Salicru SPS One 500VA V2 SAI")

#figure(
  image("./images/sai-salicru.jpg", width: width),
  caption: [ SAI Salicru SPS One 700VA 360W  ],
)

Entre las distintas opciones del mercado compatibles con los requisitos establecidos, el modelo *Salicru SPS One 700 VA* se presenta como una opción particularmente adecuada para el presente proyecto NAS DIY. Se trata de un *SAI de formato mini torre* con *topología Line-Interactive*, lo que le permite ofrecer no solo respaldo energético, sino también *estabilización automática de tensión (AVR)*. Esta característica es crucial en entornos donde las *fluctuaciones eléctricas* son frecuentes, ya que permite *corregir picos o caídas de voltaje sin recurrir a la batería*, prolongando así su vida útil.

En términos de capacidad, dispone de *700 VA y 360 W de potencia activa*, lo cual, como se ha demostrado en la estimación anterior, *supera con holgura* el consumo máximo proyectado del sistema (#sym.tilde.op 104 W). Este margen adicional le permite garantizar una *autonomía estimada de hasta 20 minutos*, más que suficiente para llevar a cabo un *apagado ordenado del sistema NAS* incluso ante interrupciones imprevistas.

Un aspecto clave de este modelo es la *incorporación de un puerto USB tipo B* con soporte para el *protocolo HID nativo*, lo que significa que puede ser detectado automáticamente por sistemas operativos como Linux, sin necesidad de drivers propietarios. Esta funcionalidad es esencial para permitir la *comunicación directa con el sistema operativo del NAS*, activando scripts de *apagado controlado (graceful shutdown)* mediante herramientas como *NUT (Network UPS Tools)*.

Adicionalmente, el Salicru SPS One incluye:

- *Protección contra sobretensiones, picos de corriente y cortocircuitos*, lo cual preserva la integridad tanto del hardware del NAS como de los datos almacenados.
- *Forma de onda pseudosenoidal en modo batería*, suficiente para alimentar fuentes ATX modernas y dispositivos de electrónica de consumo sin generar inestabilidades.
- *Bajo nivel de ruido operativo (#sym.lt 40 dB)*, apto para entornos domésticos.
- *Indicadores LED y alarmas acústicas*, que informan del estado de carga y eventos de fallo.
- Funciones útiles como *arranque en frío* y *reinicio automático tras retorno de energía*, que aumentan la resiliencia del sistema frente a interrupciones prolongadas.

En resumen, el *Salicru SPS One 700 VA* cumple con todos los requisitos técnicos necesarios para proteger de forma fiable un entorno NAS doméstico de gama alta, combinando autonomía, compatibilidad, eficiencia energética y protección eléctrica en un formato compacto y accesible.

= Componentes y coste inicial

A lo largo de los apartados anteriores, se ha analizado y justificado detalladamente la selección de cada uno de los componentes que conforman la arquitectura del NAS DIY propuesto. Estas decisiones han sido guiadas por criterios de eficiencia energética, durabilidad, compatibilidad, escalabilidad y coste.

En esta sección se presenta un desglose completo de los componentes seleccionados junto con su precio estimado, con el objetivo de establecer un *presupuesto inicial realista y transparente* para la implementación del sistema. Esta información permitirá además *comparar objetivamente el coste total* del proyecto frente a soluciones NAS comerciales equivalentes.

_Nota: los valores económicos aquí presentados están sujetos a variaciones según la disponibilidad del mercado, el distribuidor y la ubicación geográfica en el momento de la adquisición. Además, no se han tenido en cuenta los posibles gastos de envío, los cuales pueden incrementar el coste final del sistema._

#table(
  columns: (auto, auto, auto),
  inset: 10pt,
  table.header(
    [*Componente*], [*Nombre*], [*Precio estimado*]
  ),

  table.cell([
    Placa base, CPU, RAM y SSD
  ]),
  table.cell([
    #link("https://es.aliexpress.com/item/1005009254021608.html", "CWWK M8 i3-N355 8-bay, 32 GB DDR5, 1 TB NVMe")
  ]),
  table.cell([
    402,99 €
  ]),

  table.cell([
    Discos Duros
  ]),
  table.cell([
    #link("https://www.amazon.es/dp/B0DT9QW4L6", "2 x Seagate Exos X10 10TB")
  ]),
  table.cell([
    298,00 €
  ]),

  table.cell([
    Disipador CPU
  ]),
  table.cell([
    #link("https://es.aliexpress.com/i/1005006301753930.html", "Jonsbo HP-400S/PMT 4")
  ]),
  table.cell([
    54,99 €
  ]),

  table.cell([
    Caja
  ]),
  table.cell([
    #link("https://www.amazon.es/Jonsbo-N3-Nas-Negro/dp/B0CMVBMVHT", "Jonsbo N3 Nas - Negro")
  ]),
  table.cell([
    160,39 €
  ]),

  table.cell([
    Fuente de alimentación
  ]),
  table.cell([
    #link("https://www.pccomponentes.com/corsair-sf450-450w-sfx-80-plus-platinum-full-modular", "Corsair SF450 450W SFX 80 Plus Platinum Full Modular")
  ]),
  table.cell([
    94,99 €
  ]),

  table.cell([
    SAI
  ]),
  table.cell([
    #link("https://www.pccomponentes.com/salicru-sps-one-700va-360w", "Salicru SPS One 500VA 360W V2 SAI")
  ]),
  table.cell([
    66,99 €
  ]),

  table.cell(colspan: 2)[*Subtotal inicial*], table.cell([*1.078,35 €*]),
)

= Coste de mantenimiento

A diferencia del coste inicial, el *coste de mantenimiento* de un sistema NAS DIY se distribuye a lo largo de su vida útil e incluye factores como el reemplazo periódico de componentes perecederos y el consumo energético sostenido. Este análisis contempla los elementos que previsiblemente requerirán renovación periódica, así como una estimación mensual del gasto eléctrico, con el objetivo de ofrecer una visión integral del coste total de propiedad (TCO, *Total Cost of Ownership*).

== Componentes con desgaste

Entre todos los elementos del sistema, los *discos duros de almacenamiento* y la *batería del SAI (Sistema de Alimentación Ininterrumpida)* son los que presentan mayor probabilidad de desgaste a medio y largo plazo.

=== Discos duros

En este proyecto se han seleccionado *discos Seagate Exos X10*, una gama *enterprise-grade* diseñada para soportar altas cargas de trabajo (hasta 550 TB/año) con una *vida media entre fallos (MTBF)* de 2,5 millones de horas. En contextos domésticos, donde el volumen de escritura es mucho menor y se aplican prácticas de mantenimiento adecuadas —como la *monitorización mediante SMART*, la *gestión térmica adecuada (temperaturas estables entre 30 °C y 40 °C)*, y la *implementación de paradas controladas en lugar de apagados bruscos*—, se estima una vida útil potencial de entre *10 y 15 años*.

=== Unidad SSD

El SSD utilizado para el sistema operativo y los servicios presenta un patrón de uso con bajas tasas de escritura. Al no tratarse de una unidad utilizada para almacenamiento intensivo de datos, su degradación es significativamente menor. Por tanto, se estima una *duración útil de unos 10 años* en condiciones normales de operación.

=== Batería del SAI

Las baterías internas de los SAI —normalmente del tipo VRLA o AGM— sufren un desgaste progresivo incluso en ausencia de ciclos de descarga completos. En condiciones óptimas (clima fresco, ventilación adecuada y baja carga), pueden alcanzar una vida útil de *hasta 5 años*. Se recomienda realizar tests periódicos y considerar su reemplazo preventivo una vez alcanzado este umbral temporal.

=== Consumo eléctrico

Tal como se ha analizado en apartados anteriores, el sistema completo, incluyendo 8 discos duros y el resto del hardware, tiene un *consumo medio estimado de 108 W*. En un escenario de funcionamiento continuo (24/7), esto representa:

$ 108 "W" times 24 "h/día" times 30 "días/mes" = 77.760 "Wh/mes" = 77,76 "kWh/mes" $

Asumiendo un precio medio de *0,18 €/kWh*, el gasto eléctrico mensual se estima en:

$ 77,76 "kWh" times 0,18 "€/kWh" = 14,00€ $


=== Amortización de componentes

Para incorporar el impacto del desgaste de componentes, se realiza una *amortización mensual* basada en su vida útil estimada:

- *8 discos duros* (150€ cada uno):
  $ (8 times 150€) / (12 "años" times 12 "meses") = 8,33 "€/mes" $
- *SSD* (70€):
  $ (70€) / (12 "años" times 12 "meses") = 0,49 "€/mes" $
- *Batería del SAI* (70€):
  $ (40€) / (5 "años" times 12 "meses") = 0,67 "€/mes" $


=== Coste mensual estimado

A partir de estos datos, se obtiene la siguiente estimación de *coste mensual total de mantenimiento del sistema NAS*:

#table(
  columns: (1fr, auto),
  inset: 10pt,
  table.header(
    [*Concepto*], [*Coste estimado (€)*]
  ),
  "Consumo eléctrico mensual", "14,00€",
  "Amortización discos duros (8x)", "8,30€",
  "Amortización SSD", "0,49€",
  "Amortización batería del SAI", "0,67€",
  table.cell([*Total mensual estimado*]), table.cell([*23,48€*])
)

Este análisis pone de manifiesto que el mantenimiento de un NAS DIY con características avanzadas puede mantenerse en el entorno de *23,5 €/mes*.

== Conclusiones

Tras el análisis detallado de todos los componentes y costes asociados, se concluye que el sistema NAS DIY propuesto presenta una ventaja económica significativa tanto en términos de *coste inicial* como de *coste de mantenimiento a largo plazo*, en comparación con alternativas comerciales y servicios de almacenamiento en la nube.

El *coste de implementación inicial* del sistema asciende a *1.085,35 €*, incluyendo todos los componentes críticos del sistema: chasis, placa base, memoria RAM, discos duros, SSD, fuente de alimentación y sistema de alimentación ininterrumpida (SAI). Este valor resulta notablemente inferior al precio de los NAS comerciales de prestaciones equivalentes.

En cuanto al *coste mensual de mantenimiento*, se ha estimado en *23,50 €/mes*, considerando tanto el consumo energético continuo como la amortización de los componentes más susceptibles de degradación: discos duros, SSD y batería del SAI.

Este valor permite establecer una *comparativa directa con servicios de almacenamiento en la nube*. Por ejemplo, para alcanzar una capacidad de *40 TB* mediante Google One o iCloud, sería necesario contratar 40 unidades del plan de *1 TB por 4,99 €/mes*, lo que se traduce en un gasto mensual de *199,60 €*, es decir, *más de ocho veces* el coste del NAS propuesto. A largo plazo, esta diferencia se vuelve aún más significativa.


Respecto a los *NAS propietarios*, las opciones disponibles con al menos *8 bahías* comienzan en torno a los *1.176 €*, sin incluir componentes fundamentales como el *Sistema de Alimentación Ininterrumpida (SAI)* ni almacenamiento SSD para el sistema operativo. Además, estas configuraciones suelen estar limitadas a *8 GB de RAM*, lo cual puede resultar insuficiente para un entorno doméstico avanzado que pretenda ejecutar múltiples servicios en paralelo mediante contenedores. Las configuraciones con *32 GB de RAM*, más adecuadas para este tipo de uso, se sitúan en el entorno de los *3.000 € o más*.

En contraste, la solución *NAS DIY* propuesta en esta tesis, basada en la placa *CWWK M8 i3-N355*, permite alcanzar un sistema equivalente en prestaciones por un coste total de *780,35 € (sin incluir los discos duros)*. Esta cifra incluye todos los componentes necesarios —placa base, CPU, RAM, SSD, chasis, fuente de alimentación, disipador y SAI— y refleja una solución _más rentable, ampliable y transparente_ tanto en términos económicos como operativos.

En resumen, este estudio valida de forma concluyente que *montar un NAS de forma personalizada (DIY)* no solo es viable desde el punto de vista técnico, sino también claramente *más rentable* tanto a corto como a largo plazo. Esta solución combina eficiencia energética, escalabilidad, libertad de personalización y un control completo sobre el ecosistema digital doméstico, sin renunciar a la fiabilidad y durabilidad propias de un entorno profesional.

= Sistema operativo

== Opciones recomendadas

=== TrueNAS

=== OpenMediaVault

=== Unraid

=== NixOS

== Conclusiones

= Monitorización y alertado

== Opciones recomendadas

=== OpenMediaVault

=== Netdata

=== Prometheus + Grafana

== Conclusiones

= Conclusiones

#bibliography("./references/refs.bib")
