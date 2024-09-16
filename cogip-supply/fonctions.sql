1. Analysez le code de la fonction et essayez de comprendre chacun de ses
éléments.


--Fonction Format Date

CREATE OR REPLACE FUNCTION format_date(date date, separator varchar) 
RETURNS text LANGUAGE plpgsql 
AS $$
begin -- en plpgsql, l'opérateur de concaténation est ||
 return to_char(date, 'DD' || separator || 'MM' || separator || 'YYYY'); 
END; $$


select format_date('2023-02-01','/') 

--2. Utilisez la nouvelle fonction dans une requête permettant d’afficher toutes les
--commandes avec un tiret (‘-‘) utilisé en tant que séparateur.

CREATE OR REPLACE FUNCTION format_date(date date, separator varchar) 
RETURNS text LANGUAGE plpgsql 
AS $$
begin -- en plpgsql, l'opérateur de concaténation est ||
 return to_char(date, 'DD' || separator || 'MM' || separator || 'YYYY'); 
END; $$


select format_date('2023-02-01','-') ;

select format_date(date,'/') from "order" o ;

--3. Analysez et testez le code, comment est effectuée l’affectation de la variable
--« items_count » ?

CREATE OR REPLACE FUNCTION get_items_count()
RETURNS integer
LANGUAGE plpgsql
AS $$
declare
items_count integer;
time_now time = now();
begin
select count(id)
into items_count
from item;
--affichage de sortie: '%concatenation%' + concatenation + les variables
raise notice '% articles à %', items_count, time_now;
--retour de la foncion
return items_count;
END;
$$

select get_items_count()
into total
from item i 

--4  Implémentez une fonction: elle doit afficher(via un message « notice) 
--et retourner le nombre d’articles pour lesquels la valeur du stock est inférieure au stock d’alerte.

create or replace function stock_alert_notice()
returns integer
language plpgsql
as $$
declare 
items_alert_stock integer;
time_now time = now();
begin 
	select count(*)
    into items_alert_stock
	from item 
	where stock < stock_alert;
    raise notice'% articles sont sous le stock de sécurité de  %',items_alert_stock,time_now ;
return items_alert_stock;
end;
$$

select stock_alert_notice();


--5: La fonction doit afficher le nom du fournisseur pour lequel il y a le plus eu de commandes
--effectuées (le plus d’enregistrements dans la table « order ») et retourner son identifiant.

CREATE OR REPLACE FUNCTION name_supplier_order()  --<nom-fonction>(<paramètres>)--
RETURNS varchar(50) 
LANGUAGE plpgsql 
AS $$ -- "AS" indique le début de la définiton de la fonction
declare -- la partie "declare" permet de déclarer toutes les variables utilisées
max_order_supplier integer;
time_now time = now();
supplier_name varchar(50);

begin
	select s."name", count(o.supplier_id) 
	into supplier_name, max_order_supplier
	from  "order" o 
	join supplier s on o.supplier_id = s.id
	group by o.supplier_id ,s."name"
	order by count(o.supplier_id) desc 
	limit 1;
raise notice'% est le nom du fournisseur qui a le plus de commande  %', supplier_name,time_now;
return supplier_name;
END;
$$
	
--test
select name_supplier_order();

	select s."name" , o.supplier_id ,count(o.supplier_id) 
	from  "order" o 
	join supplier s on o.supplier_id = s.id
	group by o.supplier_id ,s."name"
	order by count(o.supplier_id) desc 
	limit 1;

--6 Proposez deux fonctions, une basée sur un « if » et une autre sur un « switch-case ».
--Elles porteront les noms « satisfaction_string_if » et « satisfaction_string_case ».

--case

CREATE OR REPLACE FUNCTION  satisfaction_string_case(satisfaction_index integer)
RETURNS varchar(50)
LANGUAGE plpgsql -- langage procédural utilisé, ici plpgsql
AS $$ -- "AS" indique le début de la définiton de la fonction
declare 
string_satisfaction varchar(50);
begin

--affectation de variable
string_satisfaction = case 
		when satisfaction_index is null then 'Sans commentaires'
		when satisfaction_index < 3 then 'Mauvais'
		when satisfaction_index < 5 then 'Passable'
		when satisfaction_index < 7 then 'Moyen'
		when satisfaction_index < 9 then 'Bon'
		when satisfaction_index < 11 then 'Excellent'
		end;
return string_satisfaction;
END;
$$

--if function

CREATE OR REPLACE FUNCTION satisfaction_string_if(satisfaction_index integer)
RETURNS varchar(50)
LANGUAGE plpgsql 
AS $$ 
declare 
string_satisfaction varchar(50);
begin
		if satisfaction_index is null then 
			string_satisfaction = 'Sans commentaires';
		elsif satisfaction_index < 3 then 
			string_satisfaction ='Mauvais';
		elsif satisfaction_index < 5 then 
			string_satisfaction ='Passable';
		elsif satisfaction_index < 7 then 
			string_satisfaction ='Moyen';
		elsif satisfaction_index < 9 then 
			string_satisfaction ='Bon';
		elsif satisfaction_index < 11 then 
			string_satisfaction ='Excellent';
 		end if;
return string_satisfaction ;
END;
$$

--7. Testez vos fonctions, en affichant le niveau de satisfaction des fournisseurs en toutes
--lettres ainsi que leur identifiant et leur nom grâce à une requête « SELECT ». 

-- test
select  s.id , s."name", satisfaction_string_if(satisfaction_index) from supplier s ;
select  s.id , s."name", satisfaction_string_case(satisfaction_index) from supplier s ;


--8 Objectif de la fonction :
--« add_days » devra prendre en paramètre une date et un nombre de jours et retourner une
--nouvelle date incrémentée du nombre de jours.

CREATE OR REPLACE FUNCTION add_days(date_to_add date, days_to_add integer) 
RETURNS date
LANGUAGE plpgsql 
AS $$ 
declare
new_date date;
begin
select date_to_add + interval '1 day' * days_to_add
into new_date;
return new_date ;
END;
$$

--test
select add_days('2023-10-10',5);
select date '2023-01-20' + integer '1'*5;

--9-1 L’objectif et de créer une fonction retournant le résultat d’une requête comptant le nombre d’articles
--proposés par un fournisseur. 

select 

CREATE OR REPLACE FUNCTION order_per_supplier(ref_id integer)
RETURNS integer 
LANGUAGE plpgsql
AS $$ 
declare 
quantity_per_supplier integer;
supplier_exists boolean; --restriction pour la fonction 
begin
--restriction avec la boucle if si le fournisseur n’existe pas
supplier_exists = exists(select * from supplier s where s.id = ref_id);
 if( supplier_exists = false) then
RAISE EXCEPTION 'L''identifiant % n''existe pas', ref_id USING HINT =
'Vérifiez l''identifiant du fournisseur.';
else
select count(item_id) as quantity_order from sale_offer
into quantity_per_supplier
where supplier_id = ref_id ;
return quantity_per_supplier;
 end if;

END;
$$

--test
select "name" ,order_per_supplier(5) from supplier ;

--voir avec ludo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;
select s."name" ,order_per_supplier(id) from supplier s
where s.id = 120;


supplier_exists boolean; --restriction pour la fonction 
begin
--restriction avec la boucle if si le fournisseur n’existe pas
supplier_exists = exists(select * from supplier s where s.id = supplier_id);
 if supplier_exists = false then
raise notice' numero id % invalid',ref_id;
 end if;


--9-2 Créez la fonction « sales_revenue », qui en fonction d’un identifiant
--fournisseur et d’une année entrée en paramètre, restituera le chiffre d’affaires
--de ce fournisseur pour l’année souhaitée.

CREATE OR REPLACE FUNCTION sales_revenue(ref_id integer; year_Date integer )
RETURNS <type-de-retour>
LANGUAGE plpgsql
AS $$ 
declare 

begin

return
END;
$$

select 





CREATE OR REPLACE FUNCTION <nom-fonction>(<paramètres>)
RETURNS <type-de-retour>
LANGUAGE plpgsql
AS $$ 
declare 

begin

return
END;
$$







--2.12 PROCEDURE DE CREATION D’UTILISATEUR
--création du tableau user
CREATE TABLE public.user (
    id serial primary key,
    email varchar(50) NOT null,
	last_login TIMESTAMP,
	"password" varchar(50) not null,
	"role" varchar(50) not null,
	connexion_attempt integer DEFAULT 0,
	blocked_account boolean DEFAULT  false

);

--création d'un utilisateur
INSERT INTO "user"(email, "password", "role")
    VALUES ('tyty@yahoo.fr', 'Yojimbo', 'admin');
    
   
--craéation de la procédure
 CREATE OR REPLACE procedure check_Field(email varchar, "password" varchar, "role" varchar)
LANGUAGE plpgsql
AS $$ 
declare 
begin

if length("password")<8 then
RAISE EXCEPTION 'password invalid' USING HINT =
'modify your password.';
elsif 
-- cette expression "!~ " signifie not like 
	"email"!~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN

    RAISE EXCEPTION 'Wrong E-mail format %', "email"
        USING HINT = 'Please check your E-mail format.';


--voir avec ludo!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
elsif "role" !~ 'MAIN_ADMIN' and "role" !~ 'ADMIN' and "role" !~ 'COMMON' THEN
    RAISE EXCEPTION 'Wrong role'USING HINT = 
					'Please enter the correct role';
end if;
END;
$$  

--test
call check_Field('rt@d.fr','212gddfgd','COMMON'); 

   
   