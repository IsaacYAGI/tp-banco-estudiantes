# TP Banco de los Estudiantes I.U.T. FRP - 2012

## Clone

```
git clone https://github.com/IsaacYAGI/tp-banco-estudiantes.git
cd tp-banco-estudiantes
```
## Compilación

Se puede hacer uso de **Bloodsheed Dev-Pascal v1.9.2** para compilarlo. Abrir el archivo \*.pas con el IDE y compilar el ejecutable presionando el botón **Compile Project**.

## Descripción del problema

##### Banco de los Estudiantes IUT

El Consejo Directivo ha pensado en una alternativa para formar valores ciudadanos en su población estudiantil, algo tan básico como el valor del Ahorro, para ello ha decidido crear el “El Banco de los Estudiantes IUT”, el cual permite a toda la población estudiantil, tanto a los del Tecnológico como a los de la Ingeniería; realizar las operaciones básicas: Depositar, Retirar, Trasferir y Pago de Servicios.

Todo estudiante debe aperturar su cuenta, la cual es única y un estudiante sólo puede tener una cuenta. Como el Banco está comenzando sus operaciones no posee Cajeros Automáticos, de manera que si un Estudiante desea movilizar su cuenta debe hacerlo personalmente en nuestra agencia en el IUT y proceder de la siguiente manera:

Tomar un numero del dispensador según la transacción que desee realizar (Deposito, Retiro, Transferencia o Pago); esto inmediatamente coloca al usuario en una cola virtual que permite al usuario descansar físicamente mientras es llamado para realizar su transacción.

A lo sumo se pueden encolar 15 personas por transacción; el dispensador funciona de la siguiente manera: El usuario introduce su clave y pulsa la letra de la operación que realizará, cada tipo de operación tiene su propio correlativo; así que se imprimirá el ticket con la letra de la transacción y las Iniciales del Cliente

Ejemplo:

```
D003(JAMS))
```
El usuario sólo debe pulsar la letra para adquirir su ticket:

- D para Deposito
- R para retiro
- T para Transferencia
- P para Pago

El banco tiene cierta política de Atención al Cliente y es la siguiente:

> Cualquiera de los cajeros atenderán a los clientes de las colas según sea la transacción en turno que corresponda, es decir, se atenderán en este orden 3 Depósitos, 2 Retiros, 2 Trasferencias y 4 Pagos de Servicio; no se alterará bajo ninguna circunstancia.

Actualmente hay 3 taquillas y cuando alguna de ellas está disponible el cajero presiona F1, F2 o F3 según sea su número de taquilla; de esta manera cualquier taquilla podrá atender cualquier tipo de transacción. Cuando un número es llamado a taquilla éste sale de la cola en la que se encontraba. En cualquier momento se pueden encolar y atender personas en el Banco. Todo el Proceso termina cuando las cuatro (4) colas quedan vacías.

Elabore una aplicación capaz de simular este comportamiento y cuando termine, el sistema debe definir:

a) ¿Cuantas operaciones hizo cada cajero?

b) ¿Cuánto Dinero Movilizó cada Cajero?

c) ¿Cliente(s) con más movimientos en un día?
