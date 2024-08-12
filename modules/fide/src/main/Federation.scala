package lila.fide
import monocle.syntax.all.*
import reactivemongo.api.bson.Macros.Annotations.Key

import lila.core.fide.Federation.*
import lila.core.fide.FideTC

case class Federation(
    @Key("_id") id: Id,
    name: Name,
    nbPlayers: Int,
    standard: Stats,
    rapid: Stats,
    blitz: Stats,
    updatedAt: Instant
):
  def stats(tc: FideTC) = tc match
    case FideTC.standard => this.focus(_.standard)
    case FideTC.rapid    => this.focus(_.rapid)
    case FideTC.blitz    => this.focus(_.blitz)
  def slug = Federation.nameToSlug(name)

// Obviously, FIDE country codes don't follow any existing standard.
// https://ratings.fide.com/top_federations.phtml
// all=[];$('#federations_table').find('tbody tr').each(function(){all.push([$(this).find('img').attr('src').slice(5,8),$(this).find('a,strong').text().trim()])})
object Federation:

  def nameToSlug(name: Name) = FidePlayer.slugify(chess.PlayerName(name))

  def idToSlug(id: Id): String = nameToSlug(name(id))

  def name(id: Id): Name = names.getOrElse(id, id.value)

  def find(str: String): Option[Id] =
    Id(str.toUpperCase).some
      .filter(names.contains)
      .orElse(bySlug.get(str))
      .orElse(bySlug.get(nameToSlug(str)))

  def namesByIds(ids: Iterable[Id]): Map[Id, Name] =
    ids.view.flatMap(id => names.get(id).map(id -> _)).toMap

  lazy val bySlug: Map[String, Id] =
    names.map: (id, name) =>
      nameToSlug(name) -> id

  val names: Map[Id, Name] = Map(
    Id("FID") -> "FIDE",
    Id("USA") -> "United States of America",
    Id("IND") -> "India",
    Id("CHN") -> "China",
    Id("RUS") -> "Russia",
    Id("AZE") -> "Azerbaijan",
    Id("FRA") -> "France",
    Id("UKR") -> "Ukraine",
    Id("ARM") -> "Armenia",
    Id("GER") -> "Germany",
    Id("ESP") -> "Spain",
    Id("NED") -> "Netherlands",
    Id("HUN") -> "Hungary",
    Id("POL") -> "Poland",
    Id("ENG") -> "England",
    Id("ROU") -> "Romania",
    Id("NOR") -> "Norway",
    Id("UZB") -> "Uzbekistan",
    Id("ISR") -> "Israel",
    Id("CZE") -> "Czech Republic",
    Id("SRB") -> "Serbia",
    Id("CRO") -> "Croatia",
    Id("GRE") -> "Greece",
    Id("IRI") -> "Iran",
    Id("TUR") -> "Turkiye",
    Id("SLO") -> "Slovenia",
    Id("ARG") -> "Argentina",
    Id("SWE") -> "Sweden",
    Id("GEO") -> "Georgia",
    Id("ITA") -> "Italy",
    Id("CUB") -> "Cuba",
    Id("AUT") -> "Austria",
    Id("PER") -> "Peru",
    Id("BUL") -> "Bulgaria",
    Id("BRA") -> "Brazil",
    Id("DEN") -> "Denmark",
    Id("SUI") -> "Switzerland",
    Id("CAN") -> "Canada",
    Id("SVK") -> "Slovakia",
    Id("LTU") -> "Lithuania",
    Id("VIE") -> "Vietnam",
    Id("AUS") -> "Australia",
    Id("BEL") -> "Belgium",
    Id("MNE") -> "Montenegro",
    Id("MDA") -> "Moldova",
    Id("KAZ") -> "Kazakhstan",
    Id("ISL") -> "Iceland",
    Id("COL") -> "Colombia",
    Id("BIH") -> "Bosnia & Herzegovina",
    Id("EGY") -> "Egypt",
    Id("FIN") -> "Finland",
    Id("MGL") -> "Mongolia",
    Id("PHI") -> "Philippines",
    Id("BLR") -> "Belarus",
    Id("LAT") -> "Latvia",
    Id("POR") -> "Portugal",
    Id("CHI") -> "Chile",
    Id("MEX") -> "Mexico",
    Id("MKD") -> "North Macedonia",
    Id("INA") -> "Indonesia",
    Id("PAR") -> "Paraguay",
    Id("EST") -> "Estonia",
    Id("SGP") -> "Singapore",
    Id("SCO") -> "Scotland",
    Id("VEN") -> "Venezuela",
    Id("IRL") -> "Ireland",
    Id("URU") -> "Uruguay",
    Id("TKM") -> "Turkmenistan",
    Id("MAR") -> "Morocco",
    Id("MAS") -> "Malaysia",
    Id("BAN") -> "Bangladesh",
    Id("ALG") -> "Algeria",
    Id("RSA") -> "South Africa",
    Id("AND") -> "Andorra",
    Id("ALB") -> "Albania",
    Id("KGZ") -> "Kyrgyzstan",
    Id("KOS") -> "Kosovo *",
    Id("FAI") -> "Faroe Islands",
    Id("ZAM") -> "Zambia",
    Id("MYA") -> "Myanmar",
    Id("NZL") -> "New Zealand",
    Id("ECU") -> "Ecuador",
    Id("CRC") -> "Costa Rica",
    Id("NGR") -> "Nigeria",
    Id("JPN") -> "Japan",
    Id("SYR") -> "Syria",
    Id("DOM") -> "Dominican Republic",
    Id("LUX") -> "Luxembourg",
    Id("WLS") -> "Wales",
    Id("BOL") -> "Bolivia",
    Id("TUN") -> "Tunisia",
    Id("UAE") -> "United Arab Emirates",
    Id("MNC") -> "Monaco",
    Id("TJK") -> "Tajikistan",
    Id("PAN") -> "Panama",
    Id("LBN") -> "Lebanon",
    Id("NCA") -> "Nicaragua",
    Id("ESA") -> "El Salvador",
    Id("ANG") -> "Angola",
    Id("TTO") -> "Trinidad & Tobago",
    Id("SRI") -> "Sri Lanka",
    Id("IRQ") -> "Iraq",
    Id("JOR") -> "Jordan",
    Id("UGA") -> "Uganda",
    Id("MAD") -> "Madagascar",
    Id("ZIM") -> "Zimbabwe",
    Id("MLT") -> "Malta",
    Id("SUD") -> "Sudan",
    Id("KOR") -> "South Korea",
    Id("PUR") -> "Puerto Rico",
    Id("HON") -> "Honduras",
    Id("GUA") -> "Guatemala",
    Id("PAK") -> "Pakistan",
    Id("JAM") -> "Jamaica",
    Id("THA") -> "Thailand",
    Id("YEM") -> "Yemen",
    Id("LBA") -> "Libya",
    Id("CYP") -> "Cyprus",
    Id("NEP") -> "Nepal",
    Id("HKG") -> "Hong Kong, China",
    Id("SSD") -> "South Sudan",
    Id("BOT") -> "Botswana",
    Id("PLE") -> "Palestine",
    Id("KEN") -> "Kenya",
    Id("AHO") -> "Netherlands Antilles",
    Id("MAW") -> "Malawi",
    Id("LIE") -> "Liechtenstein",
    Id("TPE") -> "Chinese Taipei",
    Id("AFG") -> "Afghanistan",
    Id("MOZ") -> "Mozambique",
    Id("KSA") -> "Saudi Arabia",
    Id("BAR") -> "Barbados",
    Id("NAM") -> "Namibia",
    Id("HAI") -> "Haiti",
    Id("ARU") -> "Aruba",
    Id("CIV") -> "Cote d’Ivoire",
    Id("CPV") -> "Cape Verde",
    Id("SUR") -> "Suriname",
    Id("LBR") -> "Liberia",
    Id("IOM") -> "Isle of Man",
    Id("MTN") -> "Mauritania",
    Id("BRN") -> "Bahrain",
    Id("GHA") -> "Ghana",
    Id("OMA") -> "Oman",
    Id("BRU") -> "Brunei Darussalam",
    Id("GCI") -> "Guernsey",
    Id("GUM") -> "Guam",
    Id("KUW") -> "Kuwait",
    Id("JCI") -> "Jersey",
    Id("MRI") -> "Mauritius",
    Id("SEN") -> "Senegal",
    Id("BAH") -> "Bahamas",
    Id("MDV") -> "Maldives",
    Id("NRU") -> "Nauru",
    Id("TOG") -> "Togo",
    Id("FIJ") -> "Fiji",
    Id("PLW") -> "Palau",
    Id("GUY") -> "Guyana",
    Id("LES") -> "Lesotho",
    Id("CAY") -> "Cayman Islands",
    Id("SOM") -> "Somalia",
    Id("SWZ") -> "Eswatini",
    Id("TAN") -> "Tanzania",
    Id("LCA") -> "Saint Lucia",
    Id("ISV") -> "US Virgin Islands",
    Id("SLE") -> "Sierra Leone",
    Id("BER") -> "Bermuda",
    Id("SMR") -> "San Marino",
    Id("BDI") -> "Burundi",
    Id("QAT") -> "Qatar",
    Id("ETH") -> "Ethiopia",
    Id("DJI") -> "Djibouti",
    Id("SEY") -> "Seychelles",
    Id("PNG") -> "Papua New Guinea",
    Id("DMA") -> "Dominica",
    Id("STP") -> "Sao Tome and Principe",
    Id("MAC") -> "Macau",
    Id("CAM") -> "Cambodia",
    Id("VIN") -> "Saint Vincent and the Grenadines",
    Id("BUR") -> "Burkina Faso",
    Id("COM") -> "Comoros Islands",
    Id("GAB") -> "Gabon",
    Id("RWA") -> "Rwanda",
    Id("CMR") -> "Cameroon",
    Id("MLI") -> "Mali",
    Id("ANT") -> "Antigua and Barbuda",
    Id("CHA") -> "Chad",
    Id("GAM") -> "Gambia",
    Id("COD") -> "Democratic Republic of the Congo",
    Id("SKN") -> "Saint Kitts and Nevis",
    Id("BHU") -> "Bhutan",
    Id("NIG") -> "Niger",
    Id("GRN") -> "Grenada",
    Id("BIZ") -> "Belize",
    Id("CAF") -> "Central African Republic",
    Id("ERI") -> "Eritrea",
    Id("GEQ") -> "Equatorial Guinea",
    Id("IVB") -> "British Virgin Islands",
    Id("LAO") -> "Laos",
    Id("SOL") -> "Solomon Islands",
    Id("TGA") -> "Tonga",
    Id("TLS") -> "Timor-Leste",
    Id("VAN") -> "Vanuatu"
  )
