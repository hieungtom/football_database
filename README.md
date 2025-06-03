# Football from above

<p>School project involving a database.</p> 

<p>With this course I've learnt to create a conceptual model and then based on that create and fill the database using PostgreSQL. I also tested the database with various SQL quaries and relational algebras.</p>

<h2>Conceptual model in czech:</h2>

![image](https://github.com/user-attachments/assets/63b2987b-65ab-4541-8fed-86b80b0f3a9f)

<h2>Description of the poject in czech:</h2>
<h3>Fotbal shora</h3>

<p>Databáze Fotbal shora se zaměřuje na evidenci komplexních aspektů fotbalového světa, především hráčů, klubů a jejich činností. Klíčovými entitami jsou hráč, klub, trenér a zápas, přičemž databáze zajišťuje jejich vzájemné propojení. Hráči mohou být smluvně vázáni ke klubům pomocí entity kontrakt, která eviduje dobu trvání jejich smlouvy. Tato entita rovněž umožňuje sledovat smlouvy trenérů, přičemž zajišťuje, že hráč a trenér nemohou být současně zapsáni pod jedním kontraktem.</p>

<p>Každý klub má svého trenéra a také domácí stadion, jehož název a kapacita jsou v databázi zaznamenány. Kluby soutěží v různých ligách, což umožňuje entita liga, která ukládá informace o názvu ligy a zemi, kde liga probíhá. Kromě toho mohou kluby vyhrávat různé trofeje, které jsou evidovány v entitě trofej, spolu s počtem jejich vítězství.</p>

<p>Zápasy mezi kluby jsou v databázi zaznamenány spolu s datem, domácím a hostujícím klubem. Detailní statistiky zápasů, jako je počet vstřelených gólů, žlutých a červených karet, jsou ukládány do entity statistika. Tím je zajištěna možnost analyzovat výkon týmů i jednotlivců.
</p>

<p>Databáze Fotbal shora poskytuje podrobný přehled o hráčích, jejich kariérách, klubech a trenérech, a zároveň nabízí nástroj pro sledování výkonů v soutěžích, což je užitečné pro analýzy a rozhodování v oblasti fotbalu. Navíc zajišťuje flexibilitu díky navrženým vazbám, které umožňují rozšíření o další aspekty, jako jsou mezinárodní soutěže nebo individuální ocenění hráčů.</p>

<h2>A few SQL quaries used to test the database:</h2>
<h3>Zobraz všechny již odehrané zápasy klubů s počtem gólů domácích a hostujících.</h3>
```sql
SELECT z.datum_zapasu, domaci.nazev AS domaci_klub, hostujici.nazev AS hostujici_klub,
    SUM(CASE WHEN zh.id_hrac IN (
            SELECT id_hrac 
            FROM kontrakt 
            WHERE id_klub = z.id_domaci_klub
        ) THEN zh.gol ELSE 0 END) AS goly_domaci,
    SUM(CASE WHEN zh.id_hrac IN (
            SELECT id_hrac 
            FROM kontrakt 
            WHERE id_klub = z.id_hostujici_klub
        ) THEN zh.gol ELSE 0 END) AS goly_hostujici
FROM zapas z
JOIN klub domaci ON z.id_domaci_klub = domaci.id_klub
JOIN klub hostujici ON z.id_hostujici_klub = hostujici.id_klub
LEFT JOIN zapas_hrac zh ON z.id_zapas = zh.id_zapas
WHERE datum_zapasu < now()
GROUP BY z.datum_zapasu, domaci.nazev, hostujici.nazev
ORDER BY z.datum_zapasu DESC;
```
