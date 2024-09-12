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

CREATE OR REPLACE FUNCTION  satisfaction_string_case(satisfaction_index integer)
RETURNS varchar(50)
LANGUAGE plpgsql -- langage procédural utilisé, ici plpgsql
AS $$ -- "AS" indique le début de la définiton de la fonction
declare 
number_satisfaction integer;
string_satisfaction varchar(50);
begin

update supplier  
set satisfaction_index = 
	case 
		when satisfaction_index = null then 'Sans commentaires'
		when satisfaction_index = 1 or 2 then 'Mauvais'
		when satisfaction_index = 3 or 4 then 'Passable'
		when satisfaction_index = 5 or 6 then 'Moyen'
		when satisfaction_index = 7 or 8 then 'Bon'
		when satisfaction_index = 9 or 10 then 'Excellent'
		end ;
END;
$$

select  satisfaction_string_case(satisfaction_index) from supplier s ;
	








CREATE OR REPLACE FUNCTION <nom-fonction>(<paramètres>)
RETURNS <type-de-retour>
LANGUAGE plpgsql -- langage procédural utilisé, ici plpgsql
AS $$ -- "AS" indique le début de la définiton de la fonction
declare -- la partie "declare" permet de déclarer toutes les variables utilisées
dans le block délimité par "BEGIN-END"
<nom-variable> <type-variable>;
begin
-- ici le code de la fonction
-- ce code doit retourner une valeur en accord avec le type de retour de la
fonction
END;
$$
