# Gitflow

Gitflow es uno de los muchos workflows que existen para trabajar con GIT. Si no tienes establecido tu propio flujo de trabajo, te recomendamos utilizar Gitflow el cual ya tiene una base sólida para empezar a trabajar.
Si deseas puedes crear tu propio flujo, pero este te va a servir como punto de partida

## Cómo funciona

Gitflow utiliza un repositorio central como centro de comunicación para los diferentes desarrolladores. Su punto fuerte es la estructura de ramas (branches) que posee para controlar la evolución del proyecto. Gitflow se caracteriza por el uso de cuatro tipos de ramas diferentes.

## Historical Branches

Se utilizan dos ramas para registrar el historial de proyecto: Master y Develop. En la rama master no se desarrolla, solamente se registran los diferentes lanzamientos.
Todas las integraciones se realizan desde la rama de DEVELOP. El resto de ramas trabajan alrededor de estas dos.

### Feature Branches

Cada nueva funcionalidad debe residir en su propia rama, de esta forma en caso de existir problemas es muy rápido volver a versiones anteriores. Cuando se finaliza el desarrollo sobre la FEATURE, se fusiona con la rama de DEVELOP, **nunca con la rama MASTER**.

### Release Branches

Una vez el evolutivo se ha finalizado y se acerca la fecha de lanzamiento se crea una rama para éste, RELEASE. Las ramas releases son utilizadas para marcar o etiquetar lanzamientos de producto, (evolutivos) y poder tener identificados de forma rápida los cambios de las diferentes releases. A la rama RELEASE no se le pueden añadir nuevos evolutivos de ningún tipo, solamente la documentación asociada al lanzamiento de la release o errores puntuales.

Una vez se finalizan la rama release se tiene que fusionar tanto la rama master como la rama DEVELOP. Estas dos, siempre que realicemos una publicación, tienen que estar sincronizadas con el mismo contenido.

### Hotfix Branches

La rama mantenimiento o HOTFIX se utiliza cuando se detectan errores críticos de la aplicación. La forma de trabajar sería crear una rama proveniente de la MASTER, solventar el correctivo y fusionar con la rama MASTER.

Maintenance es la única rama que interactúa directamente con la rama MASTER, todas las demás siempre se trabaja desde la rama de DEVELOP.

# Fuente

https://medium.com/@andresdigital/como-organizar-el-flujo-de-tus-repositorios-git-ac441d29ddb