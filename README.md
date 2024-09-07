# poster-reactivo

Este proyecto consiste en la creación de un cartel dinámico e interactivo diseñado para mobiliario urbano, como una parada de autobús en Bogotá. El cartel reacciona a la entrada de un sensor ultrasónico, generando una visualización que evoluciona según la actividad cercana.

La configuración de Arduino controla un sensor y un servomotor. El sensor detecta objetos y, cuando algo está dentro de un cierto rango, el motor se detiene y una luz roja parpadea. El movimiento del motor se captura y se envía mediante comunicación serial a un programa en Processing.

En Processing, los datos provenientes de Arduino activan cambios en los elementos visuales del cartel. Cuando se detecta un objeto, círculos de colores aparecen en la pantalla, creciendo en tamaño y número con cada detección. Una cruz roja giratoria también se anima en función de la posición del servomotor, representando visualmente el movimiento del sensor mientras escanea el entorno.

A través de esta interacción, el cartel reacciona visualmente a los transeúntes, creando una experiencia atractiva y dinámica dentro del espacio urbano.

![image](https://github.com/user-attachments/assets/f46c3268-57b1-45ad-87dd-8b476544605b)

_Mockup paradero del SITP, simulación de poster reactivo._


[Ver video del circuito funcionando](https://github.com/user-attachments/assets/1580d9d3-4244-496e-99b9-0cd362ebed5a)



