personaje('Elara', 5, 100).
personaje('Kael', 3, 80).
personaje('Rin', 7, 120).

mision(m1, 'Bosque de Sombras', 2, 50).
mision(m2, 'Cueva del Dragón', 5, 120).
mision(m3, 'Torre Arcana', 7, 200).

inventario('Elara', [espada, escudo, pocion]).
inventario('Kael', [arco, flechas]).
inventario('Rin', [varita, grimorio, pocion, amuleto]).

requiere(m2, escudo).
requiere(m2, pocion).
requiere(m3, grimorio).
requiere(m3, pocion).

puede_aceptar(Personaje, ID_Mision) :-
    personaje(Personaje, Nivel, _),
    mision(ID_Mision, _, Dificultad, _), 
    Nivel >= Dificultad.

xp_acumulada(0, 0).

xp_acumulada(N, Total) :-
    N > 0,
    N1 is N - 1,
    xp_acumulada(N1, Prev),
    Total is Prev + (30 * N).

tiene_requisitos(Personaje, Objeto) :-
    inventario(Personaje, Lista),
    member(Objeto, Lista).

mismo_nivel(P1, P2) :-
    personaje(P1, N, _),
    personaje(P2, N, _),
    P1 \== P2.

es_balanceado(Personaje) :-
    personaje(Personaje, _, Vida),
    Vida =:= 100.

fusionar_equipo(P1, P2, EquipoFusionado) :-
    inventario(P1, L1),
    inventario(P2, L2),
    append(L1, L2, EquipoFusionado).

tiempo(presente).
tiempo(pasado).
tiempo(futuro).

persona(primera).
persona(segunda).  
persona(tercera).

numero(singular).
numero(plural).

ser(presente, tercera, singular, "es").
ser(pasado, tercera, singular, "fue").
ser(futuro, tercera, singular, "será").
ser(presente, primera, singular, "soy").
ser(presente, primera, plural, "somos").
ser(presente, tercera, plural, "son").
ser(pasado, tercera, plural, "fueron").
ser(futuro, tercera, plural, "serán").

conjugar_accion(Verbo, Tiempo, Persona, Numero, Conjugacion) :-
    tiempo(Tiempo),
    persona(Persona),
    numero(Numero),
    (
        Verbo = "ser" ->
        ser(Tiempo, Persona, Numero, R),
        Conjugacion = R
        ;
        Conjugacion = Verbo
    ).

generar_reporte(Personaje, MisionID, Mensaje) :-
    puede_aceptar(Personaje, MisionID),
    mision(MisionID, Nombre, _, XP),
    conjugar_accion("ser", presente, tercera, singular, FormaVerbal),
    atomic_list_concat(
        [Personaje, FormaVerbal, "capaz de completar", Nombre, "por", XP, "XP"],
        ' ',
        Mensaje
    ).

es_lista([]).
es_lista([_|_]).

entrada_a_grupo(Entrada, Entrada) :-
    es_lista(Entrada).

entrada_a_grupo(Entrada, [Entrada]) :-
    personaje(Entrada, _, _).

pueden_todos([], _).

pueden_todos([Personaje|Resto], MisionID) :-
    puede_aceptar(Personaje, MisionID),
    pueden_todos(Resto, MisionID).

inventario_grupo([], []).

inventario_grupo([Personaje|Resto], InventarioTotal) :-
    inventario(Personaje, InventarioPersonaje),
    inventario_grupo(Resto, InventarioResto),
    append(InventarioPersonaje, InventarioResto, InventarioTotal).

tiene_requisitos_mision(Inventario, MisionID) :-
    forall(requiere(MisionID, Objeto), member(Objeto, Inventario)).

xp_actualizada([], _, []).

xp_actualizada([Personaje|Resto], MisionID, [xp(Personaje, XP_Actual, XP_Mision, XP_Final)|Resultado]) :-
    personaje(Personaje, Nivel, _),
    xp_acumulada(Nivel, XP_Actual),
    mision(MisionID, _, _, XP_Mision),
    XP_Final is XP_Actual + XP_Mision,
    xp_actualizada(Resto, MisionID, Resultado).

reporte_inicio([Personaje], MisionID, Mensaje) :-
    mision(MisionID, Nombre, _, XP),
    conjugar_accion("ser", presente, tercera, singular, FormaVerbal),
    atomic_list_concat(
        [Personaje, FormaVerbal, "capaz de completar", Nombre, "por", XP, "XP"],
        ' ',
        Mensaje
    ).

reporte_inicio(Grupo, MisionID, Mensaje) :-
    Grupo = [_,_|_],
    mision(MisionID, Nombre, _, XP),
    conjugar_accion("ser", presente, tercera, plural, FormaVerbal),
    atomic_list_concat(Grupo, ', ', Nombres),
    atomic_list_concat(
        [Nombres, FormaVerbal, "capaces de completar", Nombre, "por", XP, "XP cada uno"],
        ' ',
        Mensaje
    ).

iniciar_mision(Entrada, MisionID, Mensaje, XP_Actualizada) :-
    entrada_a_grupo(Entrada, Grupo),
    Grupo = [_|_],
    pueden_todos(Grupo, MisionID),
    inventario_grupo(Grupo, Inventario),
    tiene_requisitos_mision(Inventario, MisionID),
    reporte_inicio(Grupo, MisionID, Mensaje),
    xp_actualizada(Grupo, MisionID, XP_Actualizada).

iniciar_mision(Entrada, MisionID, Mensaje) :-
    iniciar_mision(Entrada, MisionID, Mensaje, _).

%Taller de Prolog - Nuevas reglas y funcionalidades para el juego.
personaje('Naruto', 6, 110).
personaje('Natsu', 8, 130).
personaje('Neo', 4, 95).

inventario('Naruto', [lanza, pocion, amuleto]).
inventario('Natsu', [maza, pocion, escudo]).
inventario('Neo', [ballesta, pocion, grimorio]).

arma(espada, 100).
arma(arco, 75).
arma(varita, 120).
arma(lanza, 90).
arma(maza, 130).
arma(ballesta, 110).

enemigo('Duende', basico, 50).
enemigo('Hombre Lobo', intermedio, 100).
enemigo('Demonio', avanzado, 150).
enemigo('Rey Demonio', jefe_final, 200).

entrada_ataque_a_grupo(Entrada, Entrada) :-
    es_lista(Entrada).

entrada_ataque_a_grupo(Entrada, [Entrada]) :-
    Entrada = ataca(_, _).

poder_ataque(ataca(Personaje, Arma), Poder) :-
    personaje(Personaje, _, _),
    inventario(Personaje, Inventario),
    member(Arma, Inventario),
    arma(Arma, Poder).

poderes_equipo([], [], 0).

poderes_equipo([Campeon|Resto], [Poder|PoderesResto], PoderTotal) :-
    poder_ataque(Campeon, Poder),
    poderes_equipo(Resto, PoderesResto, PoderResto),
    PoderTotal is Poder + PoderResto.

descripcion_uso(ataca(Personaje, Arma), Texto) :-
    atomic_list_concat([Personaje, "con", Arma], ' ', Texto).

descripcion_campeones([Campeon], Texto) :-
    descripcion_uso(Campeon, Texto).

descripcion_campeones([Campeon1, Campeon2], Texto) :-
    descripcion_uso(Campeon1, Texto1),
    descripcion_uso(Campeon2, Texto2),
    atomic_list_concat([Texto1, "y", Texto2], ' ', Texto).

descripcion_campeones([Campeon|Resto], Texto) :-
    Resto = [_,_|_],
    descripcion_uso(Campeon, TextoCampeon),
    descripcion_campeones(Resto, TextoResto),
    atomic_list_concat([TextoCampeon, ", ", TextoResto], '', Texto).

verbo_ataque([_], "ataca").
verbo_ataque([_,_|_], "atacan").

texto_campeon([_], "el campeon", "gano").
texto_campeon([_,_|_], "los campeones", "ganaron").

texto_poderes([Poder], Texto) :-
    atomic_list_concat([Poder], '', Texto).

texto_poderes([Poder|Resto], Texto) :-
    Resto = [_|_],
    texto_poderes(Resto, TextoResto),
    atomic_list_concat([Poder, " + ", TextoResto], '', Texto).

resultado_combate(Enemigo, PoderTotal, Vida, TextoCampeon, VerboCampeon, Resultado) :-
    (
        PoderTotal >= Vida ->
        atomic_list_concat(
            [Enemigo, "fue derrotado y", TextoCampeon, VerboCampeon, "esta batalla."],
            ' ',
            Resultado
        )
        ;
        VidaRestante is Vida - PoderTotal,
        atomic_list_concat(
            [Enemigo, "sobrevivio con", VidaRestante, "de vida y los malvados ganaron esta batalla contra", TextoCampeon],
            ' ',
            Resultado
        )
    ).

ejecutar_ataque(Entrada, Enemigo) :-
    entrada_ataque_a_grupo(Entrada, Campeones),
    Campeones = [_|_],
    enemigo(Enemigo, _, Vida),
    poderes_equipo(Campeones, Poderes, PoderTotal),
    descripcion_campeones(Campeones, TextoCampeones),
    verbo_ataque(Campeones, Verbo),
    texto_campeon(Campeones, TextoCampeon, VerboCampeon),
    texto_poderes(Poderes, TextoPoderes),
    atomic_list_concat([PoderTotal, " (", TextoPoderes, ")"], '', TextoPoder),
    resultado_combate(Enemigo, PoderTotal, Vida, TextoCampeon, VerboCampeon, Resultado),
    atomic_list_concat(
        [TextoCampeones, Verbo, "a", Enemigo, "con un poder total de", TextoPoder],
        ' ',
        Inicio
    ),
    atomic_list_concat([Inicio, ". ", Resultado], '', Mensaje),
    writeln(Mensaje).