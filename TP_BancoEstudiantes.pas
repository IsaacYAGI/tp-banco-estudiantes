Program TP4;

uses crt;
//-----------------------------------CONSTANTES---------------------------------
//--------------------------------CONSTANTES CADENA-----------------------------
const
RUTA='C:\BancoIUT\';
NOMBREARCH='alumnos.dat';
//---------------------------CONSTANTES NUMÉRICAS-------------------------------
MAXCOLA=15;
MAXESTUDIANTES=100;
//-----------------------------------TECLAS-------------------------------------
F1=#59;
F2=#60;
F3=#61;
ESCAPE=#27;
VA_NULO=#0;
//------------------------------TIPO DE VARIABLES-------------------------------
type
    estudiantes=record
       inici:string[4];
       ci:string[8];           //Registro que guardara los datos de cada usuario
       password:string[4];
       movimientos:integer;
    end;
(*Tipo ticket con los datos básicos de cada usuario EN LA COLA, iniciales, la cedula y el numero de ticket*)
    ticket=record
       iniciales:string[4];
       num_ticket:integer;
       ci:string[8];
    end;
    
(*Registro con los datos de cada estudiante (iniciales, contraseña y la cantidad de movimientos que se inicializara en 0 en
cada corrida del programa) en otras palabras, la base de datos*)

    arregloestudiantes=array[1..MAXESTUDIANTES] of estudiantes;
(*Los datos del registro se guardaran en un arreglo y este a su vez se guardara en un archivo... si se registra un nuevo estudiante, se guardara en
este arreglo y luego en un archivo. En cada corrida de programa estos datos se cargaran del archivo al arreglo, de esta manera los usuarios anteriores
podran introducir su usuario y contraseña para poder tomar una transaccion a realizar y se podrán registrar usuarios nuevos y a su vez todo se
ira guardando automaticamente en un archivo*)
    cola=record
       encolados:array[1..MAXCOLA] of ticket;
       cant_elemen:integer;
       ticket:integer;
       inden_cola:char;
    end;
(*La cola se mantendra en el programa y se irá llenando o vaciando segun convenga. Cada posicion de memoria del arreglo dentro de la cola sera un
usuario que accedio a su cuenta y solicito una transaccion; cada vez que pase eso se le sumara 1 a la cantidad de elementos y cuando se atienda se le
restara 1*)
//----------------------------VARIABLES GLOBALES--------------------------------
VAR
   base_de_datos:arregloestudiantes;
   d,r,t,p:cola; //deposito, retiro, transferencias y pagos
   op:byte; //opcion del menu
   res:char; //Respuesta para el tipo de transaccion
   cant_registros,posi,caja1,caja2,caja3,turno:integer; //contadores
   dinero1,dinero2,dinero3:real;  //contadores de dinero
   mayor_movimientos:estudiantes; //persona con mayor movimiento en el dia
//---------------------------CARGAR REGISTRO------------------------------------
procedure cargar(var reg:arregloestudiantes; var i:integer);  //Entra y sale la base de datos y cantidad de registros

var
archivo:file of estudiantes;

begin
     i:=0;
     assign(archivo, RUTA+NOMBREARCH);
     { $I- }        //Directiva que se evita que se cierre el programa si no existe el archivo
     reset(archivo);
     { $I+ }
     if IOResult=0 then                //Si existe el archivo
        while not eof(archivo) do
              begin
                   i:=i+1;
                   read(archivo,reg[i]);     //Carga cada uno de los registros en el arreglo del programa
                   reg[i].movimientos:=0; //Inicializa la variable individual de cada usuario
                   gotoxy(23,18);write('Cargando registros, por favor espere');
                   clrscr;
              end
     else rewrite(archivo);    //Sino, lo crea
     close(archivo);      //Cierra el archivo y el procedimiento retorna el arreglo lleno (si hay algún registro) y la cantidad de registros en el archivo (si no hay, retorna 0)
end;
//------------------------------------GUARDAR-----------------------------------
procedure guardar(reg:arregloestudiantes; j:integer);   //Entra la base de datos y la cantidad de registros

var
i:byte;
archivo:file of estudiantes;

begin
     assign(archivo, RUTA+NOMBREARCH);             //Guardar la base de datos en un archivo
     rewrite(archivo);
     for i:=1 to j do write(archivo,reg[i]);
     close(archivo);
end;
//----------------------------------COLA LLENA----------------------------------
function cola_llena(x:cola):boolean;  //entra la cola sale boolean

begin                                             //Función que verifica si la cola está llena
     cola_llena:=x.cant_elemen=MAXCOLA;
end;
//------------------------------COLA VACIA--------------------------------------
function cola_vacia(x:cola):boolean;  //entra la cola sale boolean

begin                                         //Función que verifica si la cola está vacía
     cola_vacia:=x.cant_elemen=0;
end;
//-----------------------------BUSQUEDA EN EL ARREGLO---------------------------
function buscar(reg:arregloestudiantes; cod:string; j:integer):integer; //1. Registro 2. Lo que va a buscar 2. Caso 3. Cantidad de registros //Retorna posición

var
i:integer;

begin
     i:=0;
     repeat
           begin
                i:=i+1;
           end;
     until(i=j) or (reg[i].ci=cod); {Buscará por cedula del estudiante y si lo encuentra o llega al final de la base de datos, detiene el ciclo}
     if reg[i].ci=cod then buscar:=i else buscar:=0; //Si lo encontró, mandará la posición, sino entonces le manda el valor 0
end;
//----------------------------------APERTURA------------------------------------
procedure apertura(var reg:arregloestudiantes; var cant:integer);  //entra y sale la base de datos y la cantidad de registros

var
aux:string;

begin
     write('Introduzca cedula: ');
     readln(aux);
     if buscar(reg,aux,cant)=0 then
        begin
             reg[cant+1].ci:=aux;
             writeln;
             write('Introduzca iniciales: ');   //Procedimiento que registra a un nuevo usuario en la base de datos
             readln(reg[cant+1].inici);
             writeln;
             write('Introduzca una contrasena: ');
             readln(reg[cant+1].password);
             cant:=cant+1;
        end
     else
         begin
              clrscr;
              write('El usuario ya existe.');
         end;
end;
//--------------------------------CREAR COLA------------------------------------
procedure crear_cola(var x:cola; letra:char);   //entra y sale la cola y entra la letra que identificará a la cola

begin
     x.cant_elemen:=0;      //Procedimiento que inicializa las variables cant de elemento y ticket en 0 y le asigna una letra de identificacion a la cola
     x.ticket:=0;
     x.inden_cola:=letra;
end;
//----------------------------------ACCESAR-------------------------------------
function acceso(x:arregloestudiantes; cant:integer):integer;  //Entra la base de datos y la cantidad de registros y sale la posicion en que esta la persona en la base de datos
                                                              //Para meterla a la cola
var
aux:string;
i:integer;

begin
     acceso:=0;                              //Busca la cedula en la base de datos y a continuación verifica que la contraseña introducida sea igual a la registrada
     write('Introduzca cedula: ');           //Así se le permite al usuario perdir una transacción
     readln(aux);
     i:=buscar(x,aux,cant);
     write('Introduzca contrasena: ');
     readln(aux);
     if i<>0 then if x[i].password=aux then acceso:=i else write('Usuario o contrasena invalido.') else write('Usuario o contrasena invalido.'); //Si todo esta correcto, retornará la posicion de la persona la base de datos
     readkey;                                                                                                                                  //De lo contrario escribirar usuario o contraseña invalido y retornara al menu
end;
//----------------------------------ENCOLAR-------------------------------------
procedure encolar(var x:cola; persona:estudiantes);  // Entra y sale la cola y entra la persona a encolar

begin
     x.cant_elemen:=x.cant_elemen+1;
     x.ticket:=x.ticket+1;
     x.encolados[x.cant_elemen].iniciales:=persona.inici;
     x.encolados[x.cant_elemen].num_ticket:=x.ticket;
     x.encolados[x.cant_elemen].ci:=persona.ci;
     gotoxy(25,16);writeln('Su ticket es: ', x.inden_cola,x.encolados[x.cant_elemen].num_ticket,'(',x.encolados[x.cant_elemen].iniciales,')'); //Escribe por pantalla el ticket que le corresponde
end;
//------------------------------DESENCOLAR--------------------------------------
procedure desencolar(var x:cola; var y:ticket; var usuario:arregloestudiantes; cant_reg:integer); //entra y sale la cola, el ticket desencolado, la base de datos (para la cantidad de movimientos) y solo entra la cantidad de registros

var
i,posi:integer;

begin
     gotoxy(18,5);writeln('Ticket: ', x.inden_cola,x.encolados[1].num_ticket,'(',x.encolados[1].iniciales,')'); //Escribe por pantalla el ticket de turno
     y:=x.encolados[1]; //Manda lo que esté en el tope de la cola
     posi:=buscar(usuario,y.ci,cant_reg); //Busca al usuario en la base de datos y...
     usuario[posi].movimientos:=usuario[posi].movimientos+1;  //cambia la variable cantidad de movimientos
     for i:=1 to x.cant_elemen do x.encolados[i]:=x.encolados[i+1]; //desplaza los usuarios restantes un lugar hacia arriba
     x.cant_elemen:=x.cant_elemen-1; //Le resta 1 a la cantidad de elemementos validos en la cola
end;
//---------------------------------ATENDER--------------------------------------
procedure atender(var depo,reti,tran,pago:cola; var caj1,caj2,caj3:integer; var dincaja1,dincaja2,dincaja3:real; var base_de_datos:arregloestudiantes; cant_registros:integer; var turno:integer);
                          //Cambiará las 4 colas, cambiará las 3 variables por caja (cant movimientos), cambiará la cantidad de dinero movido por caja, cambiara la cant de movimientos por usuario,
var                       //solo entrará la cantidad de registros en la base de datos y la variable turno se cambiará durante la ejecucion del procedimiento para conservar el orden en de las colas
caj:char;
persona:ticket;
dinero:real;

begin
     clrscr;
     //turno:=1;
     repeat
           begin
                gotoxy(12,2);writeln('Presione F1 F2 o F3 para atender o Esc para volver al menu');
                caj:=readkey;
                if caj=VA_NULO then caj:=readkey; //Al usar teclas especiales, siempre hay que oprimir 2 veces porque el primer valor sera nulo (#0) con esta instruccion se hace automaticamente Información de: http://www.geocities.ws/antrahxg/pascal/especiales.html
                if (caj in [F1,F2,F3]) then  // si la tecla leida es F1 F2 o F3...
                   begin
                        if (not cola_vacia(depo)) and (turno<4) then  //Si deposito no esta vacia y el turno esta entre 1 y 3 (3 depositos de por vez)
                           begin
                                desencolar(depo,persona,base_de_datos,cant_registros); //Desencola...
                                //delay(500);
                                gotoxy(18,7);write('Introduzca el monto a depositar: '); //Pide la cantidad de dinero a depositar...
                                readln(dinero);
                           end
                        else   //SINO
                            begin
                                 if turno<4 then turno:=4; //Si la cola estaba vacia para cuando le tocaba el turno entonces cambia el valor de turno al de la siguiente cola
                                 if not cola_vacia(reti) and (turno<6) then //Si retiro no esta vacia y el turno esta entre 4 y 5 (2 retiros de por vez)
                                    begin
                                         desencolar(reti,persona,base_de_datos,cant_registros); //desencola...
                                         //delay(500);
                                         gotoxy(18,7);write('Introduzca el monto a retirar: '); //Pide la cantidad de dinero a retirar...
                                         readln(dinero);
                                    end
                                 else   //SINO
                                     begin
                                          if turno<6 then turno:=6; //Si la cola estaba vacia para cuando le tocaba el turno entonces cambia el valor de turno al de la siguiente cola
                                          if (not cola_vacia(tran)) and (turno<8) then //Si transferencias no esta vacia y el turno esta entre 6 y 7 (2 transferencias de por vez)
                                             begin
                                                  desencolar(tran,persona,base_de_datos,cant_registros);  //Desencola...
                                                  //delay(500);
                                                  gotoxy(18,7);write('Introduzca el monto a transferir: '); //Pide la cantidad de dinero a transferir...
                                                  readln(dinero);
                                             end
                                          else  //SINO
                                              begin
                                                   if turno<8 then turno:=8; //Si la cola estaba vacia para cuando le tocaba el turno entonces cambia el valor de turno al de la siguiente cola
                                                   if (not cola_vacia(pago)) and (turno<12) then //Si pagos no esta vacia y el turno esta entre 8 y 11 (4 pagos de por vez)
                                                      begin
                                                           desencolar(pago,persona,base_de_datos,cant_registros); //Desencola
                                                           //delay(500);
                                                           gotoxy(18,7);write('Introduzca el monto a pagar: '); //Pide la cantidad de dinero a pagar...
                                                           readln(dinero);
                                                      end
                                                   else if turno<12 then turno:=12;//Si la cola estaba vacia para cuando le tocaba el turno entonces cambia el valor de turno al de la siguiente cola
                                              end;                                 //En este caso es la ultima...
                                     end;
                            end;
                   end;
                   if (caj=F1) and (turno<12) then  //Si la tecla presionada es F1 y el turno llega hasta 11...
                      begin
                           caj1:=caj1+1;               //La cantidad de dinero y la cantidad de movimientos de caja 1 se incrementan
                           dincaja1:=dincaja1+dinero;
                      end;
                   if (caj=F2) and (turno<12) then     //Si la tecla presionada es F2 y el turno llega hasta 11...
                      begin
                           caj2:=caj2+1;                //La cantidad de dinero y la cantidad de movimientos de caja 2 se incrementan
                           dincaja2:=dincaja2+dinero;
                      end;
                   if (caj=F3) and (turno<12) then //Si la tecla presionada es F3 y el turno llega hasta 11...
                      begin
                           caj3:=caj3+1;
                           dincaja3:=dincaja3+dinero;  //La cantidad de dinero y la cantidad de movimientos de caja 3 se incrementan
                      end;
                   if (caj in [F1,F2,F3]) then turno:=turno+1; //Si la tecla presionada fue F1, F2 o F3 entonces incrementa el turno, sino, ignora el incremento
                   if turno=13 then turno:=1; //Si turno llega a 13 vuelve a tener valor 1 y empezar el ciclo de nuevo...
                   clrscr;
           end;
     until ((caj=ESCAPE) or ((cola_vacia(depo)) and (cola_vacia(reti)) and (cola_vacia(tran)) and (cola_vacia(pago)))); //HASTA QUE se oprima escape o las 4 colas estén vacias.
end;
//----------------------USUARIO CON MAS MOVIMIENTOS-----------------------------
function mayor_mov(reg:arregloestudiantes; cant:integer):estudiantes; //Funcion que devuelve al usuario con mas movimientos en el dia

var
i,mayor, posi:integer;

begin
     mayor:=0;
     for i:=1 to cant do  //Con un ciclo para se va comparando la cantidad de movimientos de la base de datos con una variable inicializada en 0
         begin
              if reg[i].movimientos>mayor then  //Si encuentra algo que sea mayor a ese valor...
                 begin
                      mayor:=reg[i].movimientos; //Lo reemplaza (para comparar a los demas...)
                      posi:=i; // guarda la posicion de ese usuario....
                 end;
         end;
     mayor_mov:=reg[posi]; //Retornará al usuario con mas movimientos
end;
//---------------------------PROGRAMA PRINCIPAL---------------------------------
BEGIN
   caja1:=0;
   caja2:=0;
   caja3:=0;
   dinero1:=0;        //Inicializacion de variables
   dinero2:=0;
   dinero3:=0;
   crear_cola(d,'D');
   crear_cola(r,'R');
   crear_cola(t,'T');
   crear_cola(p,'P');
   turno:=1;
   cargar(base_de_datos, cant_registros);
   repeat
         begin
              clrscr;
              writeln('Registros: ', cant_registros, ' de ', MAXESTUDIANTES); //Muestra la cantidad de usuarios registrados
              gotoxy(32,5);write('MENU PRINCIPAL');
              gotoxy(34,8);write('1. Apertura de cuenta');
              gotoxy(34,9);write('2. Apertura de operacion');
              gotoxy(34,10);write('3. Atender en taquilla');
              gotoxy(34,11);write('4. Salir');
              gotoxy(40,14);write('OPCION: ');
              gotoxy(48,14);readln(op);
              case op of
                   1:
                     begin       //Si la opcion es apertura de cuenta
                          clrscr;
                          if cant_registros=0 then //Y no hay nadie registrado todavia... (es decir, es el primero en registrarse en la base de datos)
                             begin
                                  write('Introduzca cedula: ');
                                  readln(base_de_datos[cant_registros+1].ci);      //Solictara los datos correspondientes
                                  writeln;
                                  write('Introduzca iniciales: ');
                                  readln(base_de_datos[cant_registros+1].inici);
                                  writeln;
                                  write('Introduzca una contrasena: ');
                                  readln(base_de_datos[cant_registros+1].password);
                                  cant_registros:=cant_registros+1;  //Se le sumara 1 a la cantidad de registrados en la base de datos
                             end
                          else apertura(base_de_datos,cant_registros); //Si ya hay algun registro, verificara primero que no exista ya la cedula.
                          guardar(base_de_datos,cant_registros); //Luego guardará los registros en un archivo...
                          readkey;
                     end;
                   2:
                     begin
                          clrscr;    //Si la opcion es apertura de operacion...
                          if cant_registros<>0 then   //Y solo si hay por lo menos 1 registro en la base de datos...
                             begin
                                  posi:=acceso(base_de_datos,cant_registros);  //Llamará al procedimiento de acceso y le mandara la base de datos y la cantida de registros y retornara la posicion. Si manda un valor diferente de 0 es porque tiene acceso
                                  if (posi<>0) then //Si retorna la posicion
                                     begin
                                          writeln('D para Deposito.');
                                          writeln('R para retiro.');
                                          writeln('T para Transferencia.');
                                          writeln('P para Pago.');                      //Menu para solicitar la transaccion
                                          writeln;
                                          write('Introduzca la letra de transaccion: ');
                                          readln(res);
                                          case res of
                                               'D','d':if not cola_llena(d) then encolar(d,base_de_datos[posi]) else writeln('Cola llena');
                                               'R','r':if not cola_llena(r) then encolar(r,base_de_datos[posi]) else writeln('Cola llena');  //Solo encolará si la cola no está llena ya...
                                               'T','t':if not cola_llena(t) then encolar(t,base_de_datos[posi]) else writeln('Cola llena');
                                               'P','p':if not cola_llena(p) then encolar(p,base_de_datos[posi]) else writeln('Cola llena');
                                          end;
                                          if (not (res in ['D','d','R','r','T','t','P','p'])) then writeln('Transaccion invalida'); //En caso de que la letra no sea correcta, retornará al menu
                                          readkey;
                                     end;
                             end
                          else write('No hay ningun usuario registrado.');  //Si cant_registros es 0 entonces no podra aperturar operaciones
                          readkey;
                     end;
                   3:      //Si la opcion es atender operaciones
                     begin
                          atender(d,r,t,p,caja1,caja2,caja3,dinero1,dinero2,dinero3,base_de_datos,cant_registros,turno); //Mandara las 4 colas, las 3 variables de movimientos por caja y las 3 variables de cant dinero por caja, asi como la base de datos y la cantidad de registros de la base de datos
                          if cola_vacia(d) then d.ticket:=0;
                          if cola_vacia(r) then r.ticket:=0; //Cuando se da escape dentro de ese procedimiento, este se detiene y vuelve al menu principal
                          if cola_vacia(t) then t.ticket:=0; //Pero si al retornar las 4 colas, alguna esta vacia (o todas), entonces el ticket pasara a valer 0 de nuevo
                          if cola_vacia(p) then p.ticket:=0; //Esto es para que al encolar escriba D1, D2, D3 etc, si se cancela deja encolado D3 y podra seguir encolando a partir de D4,D5 etc
                     end;                                    //Si está vacia entonces empieza por D1,D2, etc. de nuevo
                   4:
                     begin //Si la opcion es salir...
                          if (not ((cola_vacia(d)) and (cola_vacia(r)) and (cola_vacia(t)) and (cola_vacia(p)))) then //Verifica primero que las 4 colas estan vacias...  
                             begin
                                  clrscr;          //Si alguna todavia tiene elementos, no dejará cerrar el programa
                                  writeln('Aun hay alguna cola llena.');
                                  readkey;
                             end;
                     end;
              end;
              clrscr;
         end;
   until((op=4) and ((cola_vacia(d)) and (cola_vacia(r)) and (cola_vacia(t)) and (cola_vacia(p)))); //HASTA QUE la opcion sea salir y las 4 colas esten vacias
   clrscr;
//----------------------------------REPORTES------------------------------------
   mayor_movimientos:=mayor_mov(base_de_datos,cant_registros); //Llama a la funcion que retorna al usuario con mas movimientos...
   gotoxy(9,1);write('Caja 1'); gotoxy(38,1);write('Caja 2'); gotoxy(65,1);write('Caja 3');
   writeln;
   writeln;
   gotoxy(1,5);write('#Ope'); gotoxy(11,5);write(caja1); gotoxy(40,5);write(caja2);gotoxy(67,5);write(caja3);
   gotoxy(1,6);writeln('--------------------------------------------------------------------------------');
   gotoxy(1,7);write('Bs');gotoxy(10,7);write(dinero1:0:2);gotoxy(39,7);write(dinero2:0:2);gotoxy(66,7);write(dinero3:0:2);
   gotoxy(1,8);writeln('--------------------------------------------------------------------------------');
   gotoxy(18,9);write('El usuario con mas movimientos es: ');
   gotoxy(18,11);write('Iniciales: ',mayor_movimientos.inici);
   gotoxy(18,12);write('Cedula de Identidad: ',mayor_movimientos.ci);
   gotoxy(18,13);write('Numero de movimientos: ',mayor_movimientos.movimientos);
   readkey;
END.
//----------------------------FIN DEL PROGRAMA----------------------------------
