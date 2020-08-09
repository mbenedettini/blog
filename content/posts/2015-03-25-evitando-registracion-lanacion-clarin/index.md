---
title: Evitando la registración en La Nación y Clarin
author: Mariano Benedettini
date: 2015-03-25
hero: 
excerpt: 
---

UPDATE: se han tomado el trabajo de empaquetar un método similar a este en sendas extensiones para Chrome y Firefox , por lo que las instrucciones que siguen más abajo ahora carecen un poco de sentido.

------------------

Ahora resulta que a La Nación se le dio por pedir registración para leer algunos artículos. No voy a entrar en la discusión de si es conveniente o no, acá van instrucciones rápidas para esconder la registración y seguir leyendo el artículo en cuestión. La idea es acceder a la consola de Javascript (no se preocupen si no saben lo que es) y ejecutar un par de comandos para esconder el diálogo que pide registración y evita scrollear el artículo.

El primer paso es acceder a la Consola de Javascript, acá van las instrucciones para hacerlo en Chrome y en Firefox.

### Google Chrome
Abrir el menú principal (el botón con tres líneas horizontales), ir a Más herramientas > Consola de Javascript.

### Firefox
Abrir el menú principal (igual a Chrome, es el botón con tres líneas horizontales), ir a Desarrollador > Consola Web.

### Haciendo desaparecer el popup
Una vez que accedimos a la Consola de Javascript, hay que pegar el siguiente comando (para La Nación) y apretar enter:

`$('#iframe-registracion').hide(); $('div.modal-backdrop').hide(); $('body').removeClass('modal-open');`

Y para Clarin.com el comando a ejecutar en la consola de Javascript es el siguiente:

`$('#colorbox').hide(); $('#cboxOverlay').hide();`


