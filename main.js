function getRandomIntInclusive(min, max) {
	const randomBuffer = new Uint32Array(1);

	window.crypto.getRandomValues(randomBuffer);

	let randomNumber = randomBuffer[0] / (0xffffffff + 1);

	min = Math.ceil(min);
	max = Math.floor(max);
	return Math.floor(randomNumber * (max - min + 1)) + min;
}

function capitalizeFirstLetter(string) {
	return string.charAt(0).toUpperCase() + string.slice(1);
}

let thePassword = null;
String.prototype.plural = function (revert) {
	var plural = {
		"(quiz)$": "$1zes",
		"^(ox)$": "$1en",
		"([m|l])ouse$": "$1ice",
		"(matr|vert|ind)ix|ex$": "$1ices",
		"(x|ch|ss|sh)$": "$1es",
		"([^aeiouy]|qu)y$": "$1ies",
		"(hive)$": "$1s",
		"(?:([^f])fe|([lr])f)$": "$1$2ves",
		"(shea|lea|loa|thie)f$": "$1ves",
		sis$: "ses",
		"([ti])um$": "$1a",
		"(tomat|potat|ech|her|vet)o$": "$1oes",
		"(bu)s$": "$1ses",
		"(alias)$": "$1es",
		"(octop)us$": "$1i",
		"(ax|test)is$": "$1es",
		"(us)$": "$1es",
		"([^s]+)$": "$1s",
	};
	var singular = {
		"(quiz)zes$": "$1",
		"(matr)ices$": "$1ix",
		"(vert|ind)ices$": "$1ex",
		"^(ox)en$": "$1",
		"(alias)es$": "$1",
		"(octop|vir)i$": "$1us",
		"(cris|ax|test)es$": "$1is",
		"(shoe)s$": "$1",
		"(o)es$": "$1",
		"(bus)es$": "$1",
		"([m|l])ice$": "$1ouse",
		"(x|ch|ss|sh)es$": "$1",
		"(m)ovies$": "$1ovie",
		"(s)eries$": "$1eries",
		"([^aeiouy]|qu)ies$": "$1y",
		"([lr])ves$": "$1f",
		"(tive)s$": "$1",
		"(hive)s$": "$1",
		"(li|wi|kni)ves$": "$1fe",
		"(shea|loa|lea|thie)ves$": "$1f",
		"(^analy)ses$": "$1sis",
		"((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$": "$1$2sis",
		"([ti])a$": "$1um",
		"(n)ews$": "$1ews",
		"(h|bl)ouses$": "$1ouse",
		"(corpse)s$": "$1",
		"(us)es$": "$1",
		s$: "",
	};
	var irregular = {
		move: "moves",
		foot: "feet",
		goose: "geese",
		sex: "sexes",
		child: "children",
		man: "men",
		tooth: "teeth",
		person: "people",
	};
	var uncountable = [
		"sheep",
		"fish",
		"deer",
		"series",
		"species",
		"money",
		"rice",
		"information",
		"equipment",
	];
	if (uncountable.indexOf(this.toLowerCase()) >= 0) {
		return this;
	}
	for (word in irregular) {
		if (revert) {
			var pattern = new RegExp(irregular[word] + "$", "i");
			var replace = word;
		} else {
			var pattern = new RegExp(word + "$", "i");
			var replace = irregular[word];
		}
		if (pattern.test(this)) {
			return this.replace(pattern, replace);
		}
	}
	if (revert) {
		var array = singular;
	} else {
		var array = plural;
	}
	for (reg in array) {
		var pattern = new RegExp(reg, "i");
		if (pattern.test(this)) {
			return this.replace(pattern, array[reg]);
		}
	}
	return this;
};
const punctuation = ["!", ".", "?"];

function randomItem(array) {
	const { length } = array;
	if (length === 0) {
		return;
	}
	return array[getRandomIntInclusive(0, length)];
}
async function fetchLines(url) {
	const response = await fetch(url);
	const text = await response.text();
	return text.split("\n");
}
async function generate() {
	const [adjectives, nouns] = await Promise.all([
		fetchLines("./a.txt"),
		fetchLines("./n.txt"),
	]);
	return [
		randomItem(adjectives),
		randomItem(adjectives),
		randomItem(nouns).plural(),
	];
}
async function button() {
	const phrases = await generate();
	const thePassword =
		getRandomIntInclusive(2, 9) +
		" " +
		phrases.join(" ") +
		punctuation[getRandomIntInclusive(0, punctuation.length - 1)];
	document.getElementById("password").textContent = thePassword;
}
