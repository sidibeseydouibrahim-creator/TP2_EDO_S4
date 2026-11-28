// Executer depuis le dossier contenant les deux fichiers Scilab.
clear; clc;
// Le script retrouve ses fichiers meme si le dossier courant est different.
chdir(get_absolute_file_path("TP_02_Application_Etudiant.sce"));
exec("TP_02_Outils_EDO.sci",-1);

function z=f_test(t,y)
    z=1;
endfunction
[t,y,c]=integrer_edo(f_test,0,1,2,10,"euler");
if max(abs(y-(2+t)))>1d-12 then error("Test constant echoue"); end
mprintf("Test constant Euler : OK, cout=%d\n",c);

function z=f_decay(t,y)
    z=-15*y;
endfunction
Ns=[5 10 20 40 80];
methodes=["euler"]; // TODO : ajouter "heun" et "rk4" une fois completes.
resultats=[]; // methode_id : 1=euler, 2=heun, 3=rk4 (ordre fixe).
// Conserver cet ordre en ajoutant les methodes.
csvWrite([1;2;3],"TP2_methodes.csv",";",".","%d", ..
    "methode_id (1=euler, 2=heun, 3=rk4)");
for m=1:size(methodes,"*")
    E=zeros(1,size(Ns,"*")); cout=E;
    for j=1:size(Ns,"*")
        [t,y,c]=integrer_edo(f_decay,0,1,1,Ns(j),methodes(m));
        // TODO A : remplacer %nan par l'erreur maximale aux noeuds.
        E(j)=%nan;
        cout(j)=c;
    end
    for j=1:size(Ns,"*")
        p=%nan;
        if j<size(Ns,"*") then p=ordre_edo(E(j),E(j+1)); end
        resultats=[resultats; m Ns(j) 1/Ns(j) E(j) cout(j) p];
    end
end
csvWrite(resultats,"TP2_convergence.csv",";",".","%.12e", ..
    "methode_id;N;h;Emax;nfev;p_vers_ligne_suivante");
disp(resultats);
// Des NaN dans Emax signalent TODO A non termine.
// TODO B : tableau a budget egal (Euler 400, Heun 200, RK4 100 pas).
// TODO C : trajectoires et erreurs ; exclure NaN/zeros du trace log.
// CSV final : ajouter diagnostic stable/instable et ordre interpretable.
// Derniere ligne de chaque methode : p=NaN est normal (pas de suivant).

// Application thermique : un modele pedagogique, pas des mesures.
Cth=1000; H=10; P=100; Ta=20; theta0=20;
function z=f_therm(t,theta)
    z=(P-H*(theta-Ta))/Cth;
endfunction
function theta=theta_ref(t,Hval)
    eq=Ta+P/Hval;
    theta=eq+(theta0-eq)*exp(-Hval*t/Cth);
endfunction
// TODO D : horizon 1000 s, N=100,10,4 ; comparer les trois methodes.
// TODO E : reference H=8,10,12 W/K a temps fixes ; interpreter les ecarts.
// Conseils graphiques dans l'interface Scilab :
// plot2d(h,E,logflag="ll") pour un tableau d'erreurs positives.
// Ajouter titres, legendes, unites et identifier les calculs instables.
