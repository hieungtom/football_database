# Football from above

<p>School project involving a database.</p> 

<p>With this course I've learnt to create a conceptual model and then based on that create and fill the database using PostgreSQL. I also tested the database with various SQL quaries and relational algebras.</p>

<h2>Description of the poject in czech:</h2>
<h3>Fotbal shora</h3>

<p>Databáze Fotbal shora se zaměřuje na evidenci komplexních aspektů fotbalového světa, především hráčů, klubů a jejich činností. Klíčovými entitami jsou hráč, klub, trenér a zápas, přičemž databáze zajišťuje jejich vzájemné propojení. Hráči mohou být smluvně vázáni ke klubům pomocí entity kontrakt, která eviduje dobu trvání jejich smlouvy. Tato entita rovněž umožňuje sledovat smlouvy trenérů, přičemž zajišťuje, že hráč a trenér nemohou být současně zapsáni pod jedním kontraktem.</p>

<p>Každý klub má svého trenéra a také domácí stadion, jehož název a kapacita jsou v databázi zaznamenány. Kluby soutěží v různých ligách, což umožňuje entita liga, která ukládá informace o názvu ligy a zemi, kde liga probíhá. Kromě toho mohou kluby vyhrávat různé trofeje, které jsou evidovány v entitě trofej, spolu s počtem jejich vítězství.</p>

<p>Zápasy mezi kluby jsou v databázi zaznamenány spolu s datem, domácím a hostujícím klubem. Detailní statistiky zápasů, jako je počet vstřelených gólů, žlutých a červených karet, jsou ukládány do entity statistika. Tím je zajištěna možnost analyzovat výkon týmů i jednotlivců.
</p>

<p>Databáze Fotbal shora poskytuje podrobný přehled o hráčích, jejich kariérách, klubech a trenérech, a zároveň nabízí nástroj pro sledování výkonů v soutěžích, což je užitečné pro analýzy a rozhodování v oblasti fotbalu. Navíc zajišťuje flexibilitu díky navrženým vazbám, které umožňují rozšíření o další aspekty, jako jsou mezinárodní soutěže nebo individuální ocenění hráčů.</p>

<h2>Conceptual model in czech:</h2>

![image](https://github.com/user-attachments/assets/63b2987b-65ab-4541-8fed-86b80b0f3a9f)


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

<br>

<h3>Vyber kluby, které vyhrály všechny trofeje.</h3>

```sql
SELECT DISTINCT *
FROM KLUB K
WHERE NOT EXISTS (
    SELECT *
    FROM TROFEJ T
    WHERE NOT EXISTS (
        SELECT *
        FROM KLUB_TROFEJ KT
        WHERE KT.id_klub = K.id_klub AND KT.id_trofej = T.id_trofej
    )
);
```

<br>

<h3>Vypiš Španělské obránce a datumy konce jejich kontraktu. Pokud hráč nikdy neměl kontrakt, chceme mít ve výpisu informaci 'NEMA KONTRAKT'. Ve výstupu řadíme podle nejbližšího datumu vypršení kontraktu.</h3>

```sql
SELECT jmeno, prijmeni, COALESCE(TO_CHAR(MIN(konec_kontraktu), 'yyyy-mm-dd'), 'NEMA KONTRAKT') AS kontrakt
FROM hrac h
LEFT JOIN kontrakt k ON h.id_hrac = k.id_hrac
WHERE h.pozice = 'obrance' AND narodnost = 'Spanelsko'
GROUP BY jmeno, prijmeni
ORDER BY kontrakt
```

<br>

<h3>Vypiš hráče a jejich celkový počet gólů. Ve výsledku chceme jméno, příjmení, pozici a seřadíme je podle největšího počtu gólů.</h3>

```sql
SELECT DISTINCT jmeno, prijmeni, pozice,
(SELECT count(gol) FROM zapas_hrac WHERE h.id_hrac = zapas_hrac.id_hrac) as pocetGolu
FROM hrac h
ORDER BY pocetGolu DESC
```

<br>

<h3>Pro každého hráče vypiš celkový počet žlutých karet. Zajímají nás pouze hráči, kteří se narodili po roce 2000 včetně a obdrželi alespoň dvě žluté karty. Výsledek seřaď podle počtu žlutých karet vzestupně.</h3>

```sql
SELECT h.jmeno, h.prijmeni, sum(zh.zluta_karta) as pocetZlutychKaret
FROM zapas_hrac zh
JOIN hrac h ON zh.id_hrac = h.id_hrac
WHERE extract(year FROM h.datum_narozeni) >= 2000
GROUP BY h.jmeno, h.prijmeni
HAVING sum(zh.zluta_karta) > 1
ORDER BY pocetZlutychKaret asc
```
