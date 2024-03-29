import 'package:timezone_map/timezone_map.dart';

const copenhagen = GeoLocation(
  name: 'Copenhagen',
  admin: 'Capital Region',
  country: 'Denmark',
  country2: 'DK',
  latitude: 55.67594,
  longitude: 12.56553,
  timezone: 'Europe/Copenhagen',
  offset: 1.0,
);

const gothenburg = GeoLocation(
  name: 'Göteborg',
  admin: 'Vastra Gotaland',
  country: 'Sweden',
  country2: 'SE',
  latitude: 57.70716,
  longitude: 11.96679,
  timezone: 'Europe/Stockholm',
  offset: 1.0,
);

const helsinki = GeoLocation(
  name: 'Helsinki',
  admin: 'Uusimaa',
  country: 'Finland',
  country2: 'FI',
  latitude: 60.16952,
  longitude: 24.93545,
  timezone: 'Europe/Helsinki',
  offset: 2.0,
);

const oslo = GeoLocation(
  name: 'Oslo',
  admin: 'Oslo',
  country: 'Norway',
  country2: 'NO',
  latitude: 59.91273,
  longitude: 10.74609,
  timezone: 'Europe/Oslo',
  offset: 1.0,
);

const stockholm = GeoLocation(
  name: 'Stockholm',
  admin: 'Stockholm',
  country: 'Sweden',
  country2: 'SE',
  latitude: 59.32938,
  longitude: 18.06871,
  timezone: 'Europe/Stockholm',
  offset: 1.0,
);

const reykjavik = GeoLocation(
  name: 'Reykjavík',
  admin: 'Capital Region',
  country: 'Iceland',
  country2: 'IS',
  latitude: 64.13548,
  longitude: -21.89541,
  timezone: 'Atlantic/Reykjavik',
  offset: 0.0,
);

final geodata = Geodata(
  loadCities: () => kCities,
  loadAdmins: () => kAdmins,
  loadCountries: () => kCountries,
  loadTimezones: () => kTimezones,
);

const kCities = '''
3161732	Bergen	Bergen	BGO,Bargen,Berga,Bergen,Bergen (Hordaland Fylke),Bergena,Bergenas,Bergeno,Bergn,Bernken,Birgon,Bjoergvin,Björgvin,baragena,bargana,bei er gen,beleugen,bergeni,berugen,brghn,brgn,perkan,Μπέργκεν,Берген,ברגן,برغن,برگن,बार्गन,বারগেন,பேர்கன்,แบร์เกน,ბერგენი,ベルゲン,卑爾根,베르겐	60.39299	5.32415	P	PPLA	NO		46	4601			213585		20	Europe/Oslo	2021-07-30
2618425	Copenhagen	Copenhagen	CPH,Cobanhavan,Copenaga,Copenaghen,Copenaguen,Copenhaga,Copenhagen,Copenhague,Copenhaguen,Copenhaguen - Kobenhavn,Copenhaguen - København,Cóbanhávan,Hafnia,Kapehngagen,Kaupmannahoefn,Kaupmannahöfn,Keypmannahavn,Kjobenhavn,Kjopenhamn,Kjøpenhamn,Kobenhamman,Kobenhaven,Kobenhavn,Kodan,Kodaň,Koebenhavn,Koeoepenhamina,Koepenhamn,Kopenage,Kopenchage,Kopengagen,Kopenhaagen,Kopenhag,Kopenhaga,Kopenhage,Kopenhagen,Kopenhagena,Kopenhago,Kopenhāgena,Kopenkhagen,Koppenhaga,Koppenhága,Kòpenhaga,Köbenhavn,Köpenhamn,Kööpenhamina,København,Københámman,ge ben ha gen,khopenheken,kopanahagana,kopenahagena,kopenahegena,kopenhagen,kwbnhaghn,kwpnhgn,qwpnhgn,Κοπεγχάγη,Капэнгаген,Копенгаген,Копенхаген,Կոպենհագեն,קופנהאגן,קופנהגן,كوبنهاغن,كوپېنھاگېن,ܟܘܦܢܗܓܢ,कोपनहागन,কোপেনহাগেন,কোপেনহেগেন,โคเปนเฮเกน,ཀའོ་པེན་ཧ་ཀེན,კოპენჰაგენი,ኮፐንሀገን,ኮፕንሀግ,コペンハーゲン,哥本哈根,코펜하겐	55.67594	12.56553	P	PPLC	DK		17	101			1153615		14	Europe/Copenhagen	2012-11-26
2711537	Göteborg	Goeteborg	G'oteborg,GOT,Gautaborg,Geteborg,Geteborga,Geteborgas,Geuteborgo,Geŭteborgo,Gjoteborg,Gjotehbarg,Goeteborg,Goeteborq,Goteborg,Goteburg,Gotemburgo,Gotenburg,Gothembourg,Gothenburg,Gothoburgum,Gotnburg,Gottenborg,Göteborg,Göteborq,Gøteborg,Gēteborga,Nketempornk,ge de bao,ghwtnbrgh,gtbwrg,jwtnbrj,kx then beirk,yeteboli,yohateborya,yotebori,ywtbry,Γκέτεμποργκ,Гетеборг,Гьотеборг,Гётеборг,Гётэбарг,גטבורג,געטעבארג,جوتنبرج,غوتنبرغ,گووتھنبرگ,یوتبری,योहतेबोर्य,กอเทนเบิร์ก,გეტებორგი,ዬተቦርይ,ᐃᐅᑕᐳᕆ,ヨーテボリ,哥德堡,예테보리	57.70716	11.96679	P	PPLA	SE		28	1480			572799		10	Europe/Stockholm	2021-08-02
658225	Helsinki	Helsinki	Elsin'ki,Elsinki,Elzinki,Gel'sinki,HEL,Heilsinci,Heilsincí,Hel'sinki,Helsenkis,Helsingfors,Helsingi,Helsingia,Helsinki,Helsinkis,Helsinkium,Helsinko,Helsinky,Helsinqui,Helsinquia,Helsset,Helsínquia,Helsînkî,Helsėnkis,Hèlsinki,Khel'sinki,Khel'sinki osh,Khelsinki,Khelzinki,Lungsod ng Helsinki,Stadi,Xelsinki,Xélsinki,elcinki,hailasiki,he er xin ji,helasinki,helsingki,helsinki,herushinki,hlsnky,hlsnqy,hlsynky,hlsynqy,hylsynky,Èlzinki,Ħelsinki,Ελσίνκι,Гельсінкі,Хелзинки,Хелсинки,Хельсинки,Хельсинки ош,Хельсінкі,Ҳелсинкӣ,Һel'sinki,Һельсинки,Հելսինկի,הלסינקי,העלסינקי,هلسنكي,هلسنڪي,هلسینکی,هيلسينكى,هیلسینکی,ھێلسینکی,ہلسنکی,ہیلسنکی,ܗܠܣܢܩܝ,हेलसिंकी,हेल्सिन्की,হেলসিঙ্কি,ਹੈਲਸਿੰਕੀ,எல்சிங்கி,ಹೆಲ್ಸಿಂಕಿ,ഹെൽസിങ്കി,เฮลซิงกิ,ཧེལ་སིན་ཀི།,ဟယ်လ်ဆင်ကီမြို့,ჰელსინკი,ሄልሲንኪ,Ḥélsinki,ヘルシンキ,赫尔辛基,赫爾辛基,헬싱키	60.16952	24.93545	P	PPLC	FI		01	011	091		558457		26	Europe/Helsinki	2019-11-18
2692969	Malmö	Malmoe	MMA,Mal'mjo,Malm'o,Malme,Malmey,Malmo,Malmoe,Malmogia,Malmö,Malmø,Málmey,ma er mo,marume,Малме,Малмьо,Мальмё,מאלמה,マルメ,马尔莫,马尔默	55.60587	13.00073	P	PPLA	SE		27	1280			301706	10	12	Europe/Stockholm	2021-03-26
3143244	Oslo	Oslo	Asloa,Christiania,Kristiania,OSL,Ohoro,Osla,Oslas,Oslo,Oslo osh,Oslu,Osló,ajalo,ao si lu,asalo,aslw,awslw,osalo,oseullo,oslea,oslo,osuro,xxslo,ywslw,Òslo,Ósló,Ōhoro,Όσλο,Осла,Осло,Осло ош,Օսլո,אוסלו,أوسلو,ئوسلو,ئۆسلۆ,اسلو,اوسلو,ܐܘܣܠܘ,ओस्लो,অজলো,ওসলো,ਓਸਲੋ,ଅସଲୋ,ஒஸ்லோ,ഓസ്ലൊ,ออสโล,ཨོ་སི་ལོ།,အော့စလိုမြို့,ოსლო,ኦስሎ,オスロ,奥斯陆,오슬로	59.91273	10.74609	P	PPLC	NO		12	0301			580000		26	Europe/Oslo	2020-07-24
3413829	Reykjavík	Reykjavik	REK,Recwic,Refkiavik,Rehjkjavik,Reiciavicia,Reicivic,Reikiavik,Reikiavike,Reikjaveks,Reikjavik,Reikjavika,Reikjavikas,Reikjavīka,Reiquiavik,Reiquiavique,Rejk'javik,Rejkijavik,Rejkjavik,Rejkjaviko,Rekyavik,Reykiavica,Reykjavik,Reykjavikur,Reykjavík,Reykjavíkur,Reykjawik,Reykyabik,Reykyavik,Rèkyavik,Réicivíc,Rēcwīc,Rėikjavėks,kartuli,lei ke ya wei ke,leikyabikeu,re'ikiyabhika,reikyavuiku,rekavik,rekh ya wik,reki'avika,rekjabhika,rekjavika,rekyavika,reyikyavik,reykyavik,rykjawk,rykyafyk,rykyawk,rykyawyk,Ρέικιαβικ,Ρευκιαβικ,Рейкиявик,Рейкьявик,Рейкявик,Рейкявік,Рејкјавик,Рэйкявік,Ռեյկյավիկ,רייקיאוויק,רעקיאוויק,ريكيافيك,ریکجاوک,ریکیاوک,ریکیاویک,رېيكياۋىك,ڕێکیاڤیک,रेक्जाविक,रेक्याविक,রেইকিয়াভিক,ਰੇਕਿਆਵਿਕ,ରେକ୍ଜାଭିକ,ரெய்க்யவிக்,రేకవిక్,റെയിക്യാവിക്,เรคยาวิก,རེཀ་ཇ་བིཀ།,რეიკიავიკი,ქართული,ሬይኪያቪክ,レイキャヴィーク,雷克亞維克,雷克雅未克,雷克雅維克,레이캬비크	64.13548	-21.89541	P	PPLC	IS		39	0000			118918		37	Atlantic/Reykjavik	2019-09-05
3137115	Stavanger	Stavanger	SVG,Stafangur,Stavanger,Stavangera,Stavenger,sutavuangeru,Ставангер,スタヴァンゲル	58.97005	5.73332	P	PPLA	NO		14	1103			121610		15	Europe/Oslo	2018-03-15
2673730	Stockholm	Stockholm	Estocolm,Estocolme,Estocolmo,Estocolmu,Estocòlme,Estokolma,Estokolmo,Holmia,STO,Stakgol'm,Stjokolna,Stoccholm,Stoccolma,Stockholbma,Stockholm,Stockolm,Stocolm,Stocolma,Stocòlma,Stocólma,Stokcholme,Stokgol'm,Stokgol'm osh,Stokgolm,Stokhol'm,Stokholm,Stokholma,Stokholmas,Stokholmi,Stokholmo,Stokkholm,Stokkholmur,Stokkhólmur,Stokkolma,Stokol'ma,Stokolm,Stuculma,Stuokhuolms,Stócólm,Sztokholm,Sztokhòlm,Tukholma,astkhlm,satakahoma,seutogholleum,si de ge er mo,stak'hom,stakahoma,stokahoma,stwkhwlm,stwqhwlm,stxkholm,sutokkuhorumu,Štokholm,Στοκχόλμη,Стакгольм,Стокhольм,Стокгольм,Стокгольм ош,Стокольма,Стокхолм,Стокҳолм,Стёколна,Ստոկհոլմ,סטוקהולם,שטאקהאלם,استکهلم,ستوكهولم,ستۆکھۆڵم,سٹاکہوم,ܣܛܘܩܗܘܠܡ,स्टकहोम,स्टॉकहोम,स्तकहोम,স্টকহোম,ਸਟਾਕਹੋਮ,ஸ்டாக்ஹோம்,స్టాక్‌హోమ్,ಸ್ಟಾಕ್‍ಹೋಮ್,സ്റ്റോക്ക്‌ഹോം,สตอกโฮล์ม,སི་ཏོག་ཧོ་ལིམ།,စတော့ဟုမ်းမြို့,სტოკჰოლმი,ስቶኮልም,ᔅᑑᒃᓱᓪᒻ/stuukhulm,ストックホルム,斯德哥尔摩,斯德哥爾摩,스톡홀름,𐍃𐍄𐌿𐌺𐌺𐌰𐌷𐌿𐌻𐌼𐍃	59.32938	18.06871	P	PPLC	SE		26	0180			1515017		17	Europe/Stockholm	2019-11-28
634963	Tampere	Tampere	TMP,Tammerfors,Tammerforsia,Tampere,Tampereh,Tamperė,amabere,tambyry,tampele,tampere,tamprh,tan pei lei,tanpere,tmprh,Τάμπερε,Тампере,Тамперэ,Տամպերե,טמפרה,تامبيري,تامپره,تامپیرے,ٹیمپیر,तांपेरे,আমবেরে,ตัมเปเร,ტამპერე,タンペレ,坦佩雷,탐페레	61.49911	23.78712	P	PPLA	FI		06	064	837		202687		114	Europe/Helsinki	2019-09-05
3133880	Trondheim	Trondheim	Drontheim,Kaupangen,Kommun Trondheim,Nidaros,Nidrosia,THrandheimur,TRD,Troandin,Trondheim,Trondheimas,Trondhjem,Trondkhajm,Trondkhejm,Trongejm,Tronheima,Tronkhejm,Trontchaim,Truondheims,Truondhėims,te long he mu,teulonheim,thrx nd hem,toronhaimu,toronheimu,tronad'ehima,troneim,trwndhaym,trwndhyym,Þrándheimur,Τροντχαιμ,Τρόντχαιμ,Τρόντχαϊμ,Тронгейм,Трондхайм,Трондхејм,Тронхейм,טרונדהיים,تروندهايم,تروندهایم,ٹرونڈہائم,ট্রোনডেহিম,ทรอนด์เฮม,ტრონჰეიმი,トロンハイム,トロンヘイム,特隆赫姆,트론헤임	63.43049	10.39506	P	PPLA2	NO		21	5001			147139		18	Europe/Oslo	2021-02-27
633679	Turku	Turku	Abo,Aboa,TKU,Tourkou,Turcu,Turku,Turkù,Turu,Túrcú,touruku,trkw,tu er ku,tu rku,tuleuku,turku,twrkw,twrqw,Åbo,Τούρκου,Турку,Տուրկու,טורקו,ترکو,توركو,تورکو,तुर्कू,টুর্কু,ตุรกุ,တားကူးမြို့,ტურკუ,ቱርኩ,トゥルク,图尔库,圖爾庫,투르쿠	60.45148	22.26869	P	PPLA	FI		02	023	853		175945		22	Europe/Helsinki	2019-09-05
''';

const kAdmins = '''
DK.17	Capital Region	Capital Region	6418538
FI.01	Uusimaa	Uusimaa	830709
IS.39	Capital Region	Capital Region	3426182
NO.12	Oslo	Oslo	3143242
SE.26	Stockholm	Stockholm	2673722
''';

const kCountries = r'''
#ISO	ISO3	ISO-Numeric	fips	Country	Capital	Area(in sq km)	Population	Continent	tld	CurrencyCode	CurrencyName	Phone	Postal Code Format	Postal Code Regex	Languages	geonameid	neighbours	EquivalentFipsCode
DK	DNK	208	DA	Denmark	Copenhagen	43094	5484000	EU	.dk	DKK	Krone	45	####	^(\d{4})$	da-DK,en,fo,de-DK	2623032	DE	
FI	FIN	246	FI	Finland	Helsinki	337030	5244000	EU	.fi	EUR	Euro	358	#####	^(?:FI)*(\d{5})$	fi-FI,sv-FI,smn	660013	NO,RU,SE	
IS	ISL	352	IC	Iceland	Reykjavik	103000	308910	EU	.is	ISK	Krona	354	###	^(\d{3})$	is,en,de,da,sv,no	2629691		
NO	NOR	578	NO	Norway	Oslo	324220	5009150	EU	.no	NOK	Krone	47	####	^(\d{4})$	no,nb,nn,se,fi	3144096	FI,RU,SE	
SE	SWE	752	SW	Sweden	Stockholm	449964	9555893	EU	.se	SEK	Krona	46	SE-### ##	^(?:SE)*(\d{5})$	sv-SE,se,sma,fi-SE	2661886	NO,FI	
''';

const kTimezones = '''
CountryCode	TimeZoneId	GMT offset 1. Jan 2021	DST offset 1. Jul 2021	rawOffset (independant of DST)
DK	Europe/Copenhagen	1.0	2.0	1.0
FI	Europe/Helsinki	2.0	3.0	2.0
IS	Atlantic/Reykjavik	0.0	0.0	0.0
NO	Europe/Oslo	1.0	2.0	1.0
SE	Europe/Stockholm	1.0	2.0	1.0
''';
