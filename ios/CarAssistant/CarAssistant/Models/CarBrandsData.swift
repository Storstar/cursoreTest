import Foundation

// Расширенная база данных марок и моделей автомобилей (1960-настоящее время)
struct CarBrandsData {
    // Полный список марок автомобилей (расширенный)
    static let allBrands: [String] = [
        // Европейские марки
        "Acura", "Alfa Romeo", "Aston Martin", "Audi", "Bentley", "BMW", "Bugatti",
        "Citroën", "Ferrari", "Fiat", "Jaguar", "Lamborghini", "Land Rover", "Lotus",
        "Maserati", "McLaren", "Mercedes-Benz", "Mini", "Peugeot", "Porsche", "Renault",
        "Rolls-Royce", "SEAT", "Skoda", "Volkswagen", "Volvo",
        
        // Американские марки
        "Buick", "Cadillac", "Chevrolet", "Chrysler", "Dodge", "Ford", "GMC",
        "Jeep", "Lincoln", "Ram", "Tesla",
        
        // Азиатские марки
        "Genesis", "Honda", "Hyundai", "Infiniti", "Kia", "Lexus", "Mazda",
        "Mitsubishi", "Nissan", "Subaru", "Suzuki", "Toyota",
        
        // Другие марки
        "Dacia", "Lada", "Opel", "Saab", "Smart", "Tata"
    ]
    
    // Расширенные модели по маркам (включая исторические модели с 1960 года)
    static let modelsByBrand: [String: [String]] = [
        // Acura
        "Acura": ["ILX", "TLX", "RLX", "RDX", "MDX", "NSX", "Integra", "Legend", "Vigor", "CL", "RL", "TSX", "RSX", "ZDX"],
        
        // Alfa Romeo
        "Alfa Romeo": ["Giulia", "Stelvio", "Tonale", "4C", "Giulietta", "MiTo", "159", "147", "156", "166", "Spider", "GTV", "Alfetta", "Alfasud", "75", "164", "155", "33", "90", "Arna"],
        
        // Aston Martin
        "Aston Martin": ["DB11", "Vantage", "DBS", "DBX", "Rapide", "Vanquish", "DB9", "DBS", "DB7", "V8 Vantage", "DB5", "DB6", "Lagonda", "Cygnet", "One-77", "Vulcan"],
        
        // Audi
        "Audi": ["A1", "A3", "A4", "A5", "A6", "A7", "A8", "Q2", "Q3", "Q5", "Q7", "Q8", "e-tron", "TT", "R8", "RS3", "RS4", "RS5", "RS6", "RS7", "S3", "S4", "S5", "S6", "S7", "S8", "80", "90", "100", "200", "5000", "Quattro", "Coupe", "Cabriolet"],
        
        // Bentley
        "Bentley": ["Continental", "Flying Spur", "Bentayga", "Mulsanne", "Arnage", "Azure", "Brooklands", "Turbo R", "Continental R", "Continental T", "Eight"],
        
        // BMW
        "BMW": ["1 Series", "2 Series", "3 Series", "4 Series", "5 Series", "6 Series", "7 Series", "8 Series", "X1", "X2", "X3", "X4", "X5", "X6", "X7", "Z3", "Z4", "Z8", "i3", "i4", "i8", "iX", "M1", "M2", "M3", "M4", "M5", "M6", "M8", "2002", "1600", "1800", "2000", "2500", "2800", "3200", "Isetta", "600", "700"],
        
        // Bugatti
        "Bugatti": ["Chiron", "Divo", "Veyron", "EB110", "Type 57", "Type 41", "Type 35"],
        
        // Buick
        "Buick": ["Encore", "Envision", "Enclave", "LaCrosse", "Regal", "Lacrosse", "Lucerne", "Rendezvous", "Rainier", "Terraza", "Century", "LeSabre", "Park Avenue", "Riviera", "Skylark", "Electra", "Roadmaster", "Reatta", "Wildcat"],
        
        // Cadillac
        "Cadillac": ["CT4", "CT5", "CT6", "XT4", "XT5", "XT6", "Escalade", "ATS", "CTS", "XTS", "SRX", "DTS", "STS", "DeVille", "Seville", "Eldorado", "Fleetwood", "Brougham", "Cimarron", "Catera", "Allante"],
        
        // Chevrolet
        "Chevrolet": ["Spark", "Sonic", "Cruze", "Malibu", "Impala", "Camaro", "Corvette", "Trax", "Trailblazer", "Equinox", "Blazer", "Traverse", "Tahoe", "Suburban", "Silverado", "Colorado", "Aveo", "Cobalt", "Cavalier", "Monte Carlo", "Lumina", "Caprice", "Celebrity", "Citation", "Nova", "Chevelle", "El Camino", "Vega", "Monza", "Corvair", "Bel Air", "Biscayne", "Impala SS", "Chevy II", "Nova", "Camaro Z28", "Corvette Stingray"],
        
        // Chrysler
        "Chrysler": ["300", "Pacifica", "Voyager", "200", "Sebring", "PT Cruiser", "Concorde", "Intrepid", "LHS", "New Yorker", "Imperial", "LeBaron", "Fifth Avenue", "Newport", "300M", "Cirrus", "Stratus", "Aspen", "Crossfire", "Prowler"],
        
        // Citroën
        "Citroën": ["C1", "C2", "C3", "C4", "C5", "C6", "Berlingo", "C15", "C25", "C35", "DS3", "DS4", "DS5", "2CV", "Ami", "Dyane", "Visa", "BX", "XM", "Xantia", "Xsara", "C8", "C-Crosser", "C4 Picasso", "Grand C4 Picasso", "C4 Cactus", "C4 Aircross"],
        
        // Dodge
        "Dodge": ["Challenger", "Charger", "Durango", "Journey", "Grand Caravan", "Dart", "Avenger", "Caliber", "Magnum", "Intrepid", "Stratus", "Neon", "Spirit", "Shadow", "Omni", "Aries", "Dynasty", "Diplomat", "St. Regis", "Monaco", "Coronet", "Polara", "Dart", "Charger", "Super Bee", "Coronet R/T", "Challenger R/T", "Viper"],
        
        // Ferrari
        "Ferrari": ["488", "F8", "Roma", "Portofino", "SF90", "GTC4Lusso", "California", "458", "599", "612", "F430", "360", "550", "575", "456", "348", "328", "Testarossa", "512", "308", "Dino", "250", "275", "Daytona", "F40", "F50", "Enzo", "LaFerrari"],
        
        // Fiat
        "Fiat": ["500", "500X", "500L", "Panda", "Tipo", "Punto", "Bravo", "Brava", "Stilo", "Marea", "Tempra", "Croma", "Uno", "Ritmo", "Strada", "Regata", "Argenta", "131", "132", "124", "125", "128", "127", "126", "850", "600", "500", "Topolino", "Multipla", "Doblo", "Scudo", "Ducato", "Talento"],
        
        // Ford
        "Ford": ["Fiesta", "Focus", "Fusion", "Mustang", "EcoSport", "Escape", "Edge", "Explorer", "Expedition", "F-150", "Ranger", "Bronco", "Taurus", "Crown Victoria", "LTD", "Galaxie", "Fairlane", "Falcon", "Thunderbird", "Torino", "Gran Torino", "Mustang Mach 1", "Mustang Boss", "Mustang GT", "Mustang Shelby", "Pinto", "Maverick", "Comet", "Montego", "LTD II", "Granada", "Fairmont", "Tempo", "Probe", "Contour", "Escort", "ZX2", "ZX3", "Five Hundred", "Freestyle", "Freestar", "Windstar", "Aerostar", "Econoline", "Transit", "F-250", "F-350", "F-450", "F-550", "F-650", "F-750", "F-850", "Super Duty", "Lightning", "Raptor", "Excursion", "Flex", "C-Max", "Edge ST", "Explorer ST", "Bronco Sport", "Maverick"],
        
        // Genesis
        "Genesis": ["G70", "G80", "G90", "GV70", "GV80", "GV60"],
        
        // GMC
        "GMC": ["Terrain", "Acadia", "Yukon", "Sierra", "Canyon", "Envoy", "Jimmy", "Safari", "Sonoma", "Syclone", "Typhoon", "Suburban", "Savana", "Vandura", "Rally", "Caballero", "Sprint", "Electra", "Firebird", "Tempest", "LeMans", "Bonneville", "Grand Prix", "Catalina", "Star Chief", "Custom Safari", "Custom Cruiser"],
        
        // Honda
        "Honda": ["Civic", "Accord", "Insight", "Clarity", "HR-V", "CR-V", "Passport", "Pilot", "Ridgeline", "Odyssey", "Fit", "CR-Z", "S2000", "Prelude", "Integra", "Legend", "Vigor", "Ascot", "Ascot Innova", "Beat", "City", "Concerto", "CRX", "Element", "FR-V", "Horizon", "Jazz", "Life", "Logo", "Mobilio", "NSX", "Orthia", "Partner", "Quint", "Ridgeline", "Shuttle", "Stream", "Torneo", "Vamos", "Z", "Acty", "Avancier", "Crossroad", "Elysion", "Freed", "Inspire", "Lagreat", "Legend", "MDX", "Odyssey", "Pilot", "Ridgeline", "Stepwgn", "Vezel"],
        
        // Hyundai
        "Hyundai": ["Accent", "Elantra", "Sonata", "Ioniq", "Kona", "Tucson", "Santa Fe", "Palisade", "Venue", "Nexo", "Genesis", "Azera", "Equus", "Veracruz", "Tiburon", "Tucson", "Entourage", "XG", "XG350", "Scoupe", "Excel", "Pony", "Stellar", "Grandeur", "Dynasty", "Sonata", "Elantra", "Accent", "Atos", "Amica", "Getz", "Matrix", "Trajet", "Terracan", "Galloper", "H-1", "Starex", "i10", "i20", "i30", "i40", "ix20", "ix35", "ix55", "Veloster", "Genesis Coupe", "Genesis Sedan"],
        
        // Infiniti
        "Infiniti": ["Q50", "Q60", "Q70", "QX50", "QX60", "QX80", "G35", "G37", "M35", "M37", "M45", "M56", "FX35", "FX37", "FX45", "FX50", "EX35", "EX37", "J30", "I30", "I35", "Q45", "QX4", "QX56", "Q30", "QX30", "Q40", "Q70L", "QX70"],
        
        // Jaguar
        "Jaguar": ["XE", "XF", "XJ", "E-Pace", "F-Pace", "I-Pace", "F-Type", "XK", "XKR", "XFR", "XKR-S", "XJ220", "XJS", "XJ6", "XJ12", "XJ8", "S-Type", "X-Type", "Mark II", "Mark X", "420", "420G", "E-Type", "D-Type", "C-Type", "XK120", "XK140", "XK150", "Mark IX", "Mark VIII", "Mark VII", "Mark VI", "Mark V", "SS 100", "SS 90"],
        
        // Jeep
        "Jeep": ["Renegade", "Compass", "Cherokee", "Grand Cherokee", "Wrangler", "Gladiator", "Wagoneer", "Commander", "Liberty", "Patriot", "Compass", "Grand Wagoneer", "CJ-5", "CJ-7", "CJ-8", "Wrangler YJ", "Wrangler TJ", "Wrangler JK", "Wrangler JL", "Cherokee XJ", "Cherokee KJ", "Cherokee KK", "Grand Cherokee ZJ", "Grand Cherokee WJ", "Grand Cherokee WK", "Grand Cherokee WK2", "Commander XK", "Wagoneer SJ", "Grand Wagoneer SJ"],
        
        // Kia
        "Kia": ["Rio", "Forte", "Optima", "K5", "Stinger", "Soul", "Seltos", "Sportage", "Sorento", "Telluride", "Carnival", "Sedona", "Borrego", "Mohave", "Magentis", "Cee'd", "Pro_cee'd", "Venga", "Picanto", "Pride", "Spectra", "Shuma", "Sephia", "Mentor", "Clarus", "Credos", "Enterprise", "Potentia", "Concord", "Capital", "Besta", "Pregio", "Retona", "Rocsta", "Sportage", "Sorento", "Borrego", "Mohave", "Cadenza", "K900", "Quoris", "Opirus", "Amanti", "K7", "K9", "Niro", "EV6", "EV9"],
        
        // Lamborghini
        "Lamborghini": ["Huracán", "Aventador", "Urus", "Gallardo", "Murciélago", "Diablo", "Countach", "Jalpa", "Silhouette", "Espada", "Islero", "Jarama", "Miura", "350GT", "400GT", "LM002", "Reventón", "Sesto Elemento", "Veneno", "Centenario", "Sián", "Countach LPI 800-4"],
        
        // Land Rover
        "Land Rover": ["Discovery", "Discovery Sport", "Range Rover", "Range Rover Sport", "Range Rover Evoque", "Range Rover Velar", "Defender", "Freelander", "LR2", "LR3", "LR4", "Range Rover Classic", "Series I", "Series II", "Series III", "90", "110", "130", "Defender 90", "Defender 110", "Defender 130"],
        
        // Lexus
        "Lexus": ["IS", "ES", "GS", "LS", "UX", "NX", "RX", "GX", "LX", "LC", "RC", "CT", "HS", "LFA", "SC", "IS F", "GS F", "RC F", "LFA"],
        
        // Lincoln
        "Lincoln": ["MKZ", "Continental", "Corsair", "Nautilus", "Aviator", "Navigator", "MKS", "MKT", "MKX", "MKC", "Town Car", "Mark VIII", "Mark VII", "Mark VI", "Mark V", "Mark IV", "Mark III", "Mark II", "Continental Mark", "LS", "Blackwood", "Aviator", "Navigator", "Zephyr", "MKZ", "MKS", "MKT", "MKX", "MKC"],
        
        // Maserati
        "Maserati": ["Ghibli", "Quattroporte", "Levante", "MC20", "GranTurismo", "GranCabrio", "3200 GT", "Coupe", "Spyder", "Biturbo", "Khamsin", "Bora", "Merak", "Indy", "Mexico", "Sebring", "3500 GT", "5000 GT", "A6", "250F", "Birdcage", "MC12"],
        
        // Mazda
        "Mazda": ["Mazda2", "Mazda3", "Mazda6", "CX-3", "CX-30", "CX-5", "CX-9", "MX-5", "MX-5 Miata", "RX-7", "RX-8", "929", "626", "323", "Protege", "Millenia", "MPV", "Tribute", "B-Series", "Navajo", "CX-7", "CX-9", "MX-3", "MX-6", "Protege5", "Speed3", "Speed6", "RX-7", "RX-8", "Cosmo", "Luce", "Capella", "Familia", "Atenza", "Axela", "Demio", "Premacy", "Biante", "Eunos", "Xedos", "Autozam", "Efini"],
        
        // McLaren
        "McLaren": ["720S", "765LT", "Artura", "GT", "570S", "570GT", "540C", "650S", "675LT", "P1", "12C", "MP4-12C", "F1", "F1 LM", "F1 GT", "F1 GTR", "F1 Longtail", "Senna", "Speedtail", "Elva", "Sabre"],
        
        // Mercedes-Benz
        "Mercedes-Benz": ["A-Class", "B-Class", "C-Class", "E-Class", "S-Class", "CLA", "CLS", "GLA", "GLB", "GLC", "GLE", "GLS", "G-Class", "SL", "SLC", "SLK", "SLR", "AMG GT", "CL", "CLK", "CLS", "R-Class", "M-Class", "GL-Class", "G-Class", "SL-Class", "SLK-Class", "CLK-Class", "CL-Class", "SLR McLaren", "190", "200", "220", "230", "240", "250", "260", "280", "300", "350", "380", "400", "420", "450", "500", "560", "600", "W123", "W124", "W126", "W140", "W201", "W202", "W203", "W204", "W205", "W210", "W211", "W212", "W213", "W220", "W221", "W222", "W223", "R107", "R129", "R230", "R231", "C107", "C126", "C140", "C215", "C216", "C217", "W463", "X164", "X166", "X167", "W163", "W164", "W166", "W167", "X156", "X247", "X253", "X294", "C117", "C118", "W246", "W247", "X156", "X247", "C117", "C118", "W246", "W247"],
        
        // Mini
        "Mini": ["Hardtop", "Countryman", "Clubman", "Convertible", "Paceman", "Coupe", "Roadster", "Mini", "Mini Cooper", "Mini Cooper S", "Mini John Cooper Works", "Mini One", "Mini Cooper D", "Mini Cooper SD", "Mini Electric"],
        
        // Mitsubishi
        "Mitsubishi": ["Mirage", "Outlander", "Outlander Sport", "Eclipse Cross", "Eclipse", "Galant", "Lancer", "Lancer Evolution", "3000GT", "Diamante", "Montero", "Montero Sport", "Raider", "Endeavor", "i-MiEV", "Outlander PHEV", "Pajero", "Shogun", "L200", "Triton", "Strada", "Colt", "Carisma", "Space Star", "Space Wagon", "Space Runner", "Chariot", "Grandis", "Delica", "L300", "L400", "Express", "FTO", "GTO", "Starion", "Cordia", "Tredia", "Sigma", "Debonair", "Diamante", "Eterna", "Galant Lambda", "Sapporo", "Starion", "Tredia", "Cordia", "Sigma", "Debonair"],
        
        // Nissan
        "Nissan": ["Versa", "Sentra", "Altima", "Maxima", "Kicks", "Rogue", "Rogue Sport", "Murano", "Pathfinder", "Armada", "Frontier", "Titan", "370Z", "GT-R", "Leaf", "Juke", "Cube", "Quest", "Xterra", "370Z", "350Z", "300ZX", "280ZX", "240Z", "200SX", "240SX", "Silvia", "180SX", "200SX", "240SX", "300ZX", "350Z", "370Z", "GT-R", "Skyline", "Fairlady Z", "Pulsar", "Almera", "Primera", "Bluebird", "Sunny", "Sentra", "Altima", "Maxima", "Cefiro", "Laurel", "Cedric", "Gloria", "Fuga", "Cima", "President", "Leopard", "Skyline", "Stagea", "Avenir", "Largo", "Prairie", "Rasheen", "X-Trail", "Terrano", "Patrol", "Pathfinder", "Armada", "Quest", "Elgrand", "Serena", "Lafesta", "Wingroad", "AD", "AD Expert", "Atlas", "Cabstar", "Clipper", "Condor", "Datsun", "Frontier", "Homy", "Interstar", "NV200", "NV300", "NV400", "NT400", "NT500", "NT450", "NT350", "NT100", "NT150", "NT200", "NT250", "NT300", "NT350", "NT400", "NT450", "NT500", "Urvan", "Vanette", "Caravan", "Civilian", "Elgrand", "Quest", "Serena", "Lafesta", "Wingroad"],
        
        // Porsche
        "Porsche": ["718", "911", "Panamera", "Macan", "Cayenne", "Taycan", "Boxster", "Cayman", "928", "944", "968", "924", "914", "912", "356", "550", "904", "906", "907", "908", "909", "910", "917", "918", "919", "Carrera GT", "959", "962", "993", "996", "997", "991", "992"],
        
        // Ram
        "Ram": ["1500", "2500", "3500", "ProMaster", "ProMaster City", "1500 Classic", "2500 Classic", "3500 Classic", "4500", "5500", "6500", "7500", "8500", "1500 TRX", "1500 Rebel", "1500 Laramie", "1500 Limited", "1500 Big Horn", "1500 Tradesman", "1500 Express", "1500 SLT", "1500 ST", "1500 SLT Plus", "1500 Lone Star", "1500 Outdoorsman", "1500 Sport", "1500 R/T", "1500 Longhorn", "1500 Limited Longhorn"],
        
        // Rolls-Royce
        "Rolls-Royce": ["Ghost", "Wraith", "Dawn", "Cullinan", "Phantom", "Silver Shadow", "Silver Spirit", "Silver Spur", "Silver Dawn", "Silver Cloud", "Silver Wraith", "Silver Ghost", "Phantom I", "Phantom II", "Phantom III", "Phantom IV", "Phantom V", "Phantom VI", "Phantom VII", "Phantom VIII", "Corniche", "Camargue", "Park Ward", "Bentley", "Silver Seraph", "Silver Seraph", "Park Ward", "Corniche", "Camargue"],
        
        // Subaru
        "Subaru": ["Impreza", "Legacy", "WRX", "BRZ", "Crosstrek", "Forester", "Outback", "Ascent", "Tribeca", "Baja", "SVX", "XT", "Loyale", "Justy", "Rex", "Vivio", "Pleo", "Sambar", "Domingo", "Leone", "Legacy", "Impreza", "Forester", "Outback", "Baja", "Tribeca", "BRZ", "WRX", "STI", "Crosstrek", "Ascent", "Levorg", "Exiga", "Traviq", "B9 Tribeca", "Baja", "SVX", "XT", "Loyale", "Justy", "Rex", "Vivio", "Pleo", "Sambar", "Domingo", "Leone"],
        
        // Tesla
        "Tesla": ["Model S", "Model 3", "Model X", "Model Y", "Cybertruck", "Roadster", "Model S Plaid", "Model X Plaid", "Model 3 Performance", "Model Y Performance", "Roadster 2.0"],
        
        // Toyota
        "Toyota": ["Corolla", "Camry", "Avalon", "Prius", "Mirai", "C-HR", "RAV4", "Highlander", "4Runner", "Sequoia", "Land Cruiser", "Tacoma", "Tundra", "Sienna", "Yaris", "Yaris iA", "Yaris L", "Vios", "Etios", "Platz", "Echo", "Tercel", "Starlet", "Corolla", "Corolla iM", "Corolla Hatchback", "Corolla Cross", "Camry", "Avalon", "Prius", "Prius C", "Prius V", "Prius Prime", "Mirai", "C-HR", "RAV4", "RAV4 Prime", "Highlander", "Highlander Hybrid", "4Runner", "Sequoia", "Land Cruiser", "Land Cruiser Prado", "FJ Cruiser", "Tacoma", "Tundra", "Sienna", "Sienna Hybrid", "Previa", "Estima", "Alphard", "Vellfire", "Noah", "Voxy", "Esquire", "Isis", "Wish", "bB", "xA", "xB", "xD", "tC", "xA", "xB", "xD", "tC", "Matrix", "Venza", "Harrier", "Kluger", "Fortuner", "Hilux", "Hiace", "Coaster", "Dyna", "Toyoace", "Liteace", "Townace", "Masterace", "HiAce", "Probox", "Succeed", "Porte", "Spade", "Sienta", "Passo", "Ractis", "Ist", "Scion xA", "Scion xB", "Scion xD", "Scion tC", "Scion iQ", "Scion FR-S", "Scion iM", "Scion iA", "Celica", "Supra", "MR2", "MR-S", "86", "GR86", "Supra", "Crown", "Mark X", "Mark II", "Chaser", "Cresta", "Aristo", "Soarer", "Altezza", "Verossa", "Brevis", "Progres", "Windom", "Camry", "Avalon", "Cressida", "Corona", "Carina", "Carina ED", "Carina II", "Carina E", "Carina T", "Carina Ti", "Carina GT", "Carina GT-Four", "Carina EXi", "Carina ED", "Carina II", "Carina E", "Carina T", "Carina Ti", "Carina GT", "Carina GT-Four", "Carina EXi"],
        
        // Volkswagen
        "Volkswagen": ["Jetta", "Passat", "Arteon", "Atlas", "Atlas Cross Sport", "Tiguan", "Touareg", "ID.4", "Golf", "Golf GTI", "Golf R", "Golf SportWagen", "Golf Alltrack", "Beetle", "CC", "Eos", "Routan", "Touareg", "Tiguan", "Atlas", "Atlas Cross Sport", "ID.4", "Polo", "Up!", "Lupo", "Fox", "Gol", "Voyage", "Saveiro", "Amarok", "T-Cross", "T-Roc", "Touareg", "Tiguan", "Atlas", "Atlas Cross Sport", "ID.4", "ID.3", "ID.6", "ID.Buzz", "e-Golf", "e-Up!", "Golf", "Golf GTI", "Golf R", "Golf SportWagen", "Golf Alltrack", "Jetta", "Passat", "Arteon", "CC", "Eos", "Beetle", "Scirocco", "Corrado", "Karmann Ghia", "Type 1", "Type 2", "Type 3", "Type 4", "411", "412", "1500", "1600", "Squareback", "Fastback", "Notchback", "Karmann Ghia", "Type 1", "Type 2", "Type 3", "Type 4", "411", "412", "1500", "1600", "Squareback", "Fastback", "Notchback"],
        
        // Volvo
        "Volvo": ["S60", "S90", "V60", "V90", "XC40", "XC60", "XC90", "C30", "C70", "S40", "S60", "S70", "S80", "S90", "V40", "V50", "V60", "V70", "V90", "XC40", "XC60", "XC70", "XC90", "240", "260", "740", "760", "780", "850", "940", "960", "S40", "S60", "S70", "S80", "S90", "V40", "V50", "V60", "V70", "V90", "XC40", "XC60", "XC70", "XC90", "C30", "C70", "C30", "C70", "S40", "S60", "S70", "S80", "S90", "V40", "V50", "V60", "V70", "V90", "XC40", "XC60", "XC70", "XC90"]
    ]
    
    // Получить модели для марки
    static func getModels(for brand: String) -> [String] {
        return modelsByBrand[brand] ?? []
    }
    
    // Поиск марок по запросу (автокомплит)
    static func searchBrands(query: String) -> [String] {
        if query.isEmpty {
            return allBrands
        }
        let lowerQuery = query.lowercased()
        return allBrands.filter { brand in
            brand.lowercased().contains(lowerQuery)
        }
    }
    
    // Поиск моделей по запросу (автокомплит)
    static func searchModels(for brand: String, query: String) -> [String] {
        let models = getModels(for: brand)
        if query.isEmpty {
            return models
        }
        let lowerQuery = query.lowercased()
        return models.filter { model in
            model.lowercased().contains(lowerQuery)
        }
    }
}
