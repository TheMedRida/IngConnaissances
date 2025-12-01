% ================================
%   Faits dynamiques
% ================================
:- dynamic repond/2.

% ================================
%   PARTIE 1 : Connaissances medicales
% ================================

% Définition des symptômes lisibles
etiquette(fievre, 'fievre').
etiquette(toux, 'toux').
etiquette(mal_gorge, 'mal de gorge').
etiquette(fatigue, 'fatigue').
etiquette(courbatures, 'courbatures').
etiquette(eternuements, 'eternuements').
etiquette(nez_qui_coule, 'nez qui coule').

% Règles des maladies (version différente)
est_malade(grippe) :-
    present(fievre),
    present(courbatures),
    present(fatigue),
    present(toux).

est_malade(angine) :-
    present(mal_gorge),
    present(fievre),
    absence(toux).

est_malade(covid) :-
    present(fievre),
    present(toux),
    present(fatigue).

est_malade(allergie) :-
    present(eternuements),
    present(nez_qui_coule),
    absence(fievre).

% ================================
%   PARTIE 2 : Interaction utilisateur
% ================================

% Vérifie si un symptôme est oui/non ou pose la question si inconnu
present(S) :-
    repond(S, oui), !.

present(S) :-
    repond(S, non), !, fail.

present(S) :-
    \+ repond(S, _),
    etiquette(S, Nom),
    format('Avez-vous ~w ? (o/n) : ', [Nom]),
    get_char(R), get_char(_),
    (R = o ->
        assertz(repond(S, oui))
    ;
        assertz(repond(S, non)),
        fail
    ).

% absence = symptôme nié
absence(S) :-
    repond(S, non), !.

absence(S) :-
    \+ repond(S, _),
    etiquette(S, Nom),
    format('Avez-vous ~w ? (o/n) : ', [Nom]),
    get_char(R), get_char(_),
    (R = o ->
        assertz(repond(S, oui)),
        fail
    ;
        assertz(repond(S, non))
    ).

% ================================
%   PARTIE 3 : Lancement de l’expert
% ================================

expert :-
    nl, write('===== SYSTEME EXPERT MEDICAL ====='), nl,
    write('Répondez uniquement par o ou n.'), nl, nl,
    retractall(repond(_, _)),
    findall(M, est_malade(M), Liste),
    afficher_diagnostics(Liste).

afficher_diagnostics([]) :-
    write('Aucun diagnostic possible.'), nl.

afficher_diagnostics(L) :-
    write('Maladie(s) potentielle(s) :'), nl,
    explanations(L).

% ================================
%   PARTIE 4 : Explications
% ================================

explanations([]).
explanations([M|R]) :-
    format(' - ~w ', [M]),
    expliquer(M),
    nl,
    explanations(R).

% Construire une explication basée sur les symptômes confirmés
expliquer(Maladie) :-
    findall(Symbole,
        (repond(Symbole, oui), etiquette(Symbole, _)),
        Liste),
    write('(car : '),
    afficher_liste(Liste),
    write(')').

afficher_liste([]).
afficher_liste([E]) :- format('~w', [E]).
afficher_liste([E|R]) :-
    format('~w, ', [E]),
    afficher_liste(R).

% ================================
%   Message daccueil
% ================================
:- write('Tapez start. pour démarrer le diagnostic.'), nl.
