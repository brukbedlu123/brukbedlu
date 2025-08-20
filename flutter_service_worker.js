'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "420f28cb12a2268025b82445fc0edb8d",
"assets/AssetManifest.bin.json": "26c1cdfc0886d87b9551e390d2abe3fa",
"assets/AssetManifest.json": "e74b68ee54a548eaefdf4856d7a94883",
"assets/assets/audio/bleep.mp3": "3c8672b8034ec19e8475a6f4b2e7ca0c",
"assets/assets/audio/getready.mp3": "e6790c53b53440e93f45804c061ca92f",
"assets/assets/audio/takeabreak.mp3": "9dd5fc254b737dd5005b82ca192bc831",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "8bd2beca5c60cbc6968fc8b3d6110079",
"assets/images/app%2520bar/boy.webp": "da4a611fbf0a67de0a325f1979e3f8a6",
"assets/images/app%2520bar/girl.webp": "0c33d2bb3599139d5bed164f60b5e585",
"assets/images/discovery/belly%2520fat%2520girl.webp": "1810bc3baecd30a1760efc5800aafabc",
"assets/images/discovery/belly%2520fat.webp": "09d68a42530f59ba486cb7d81c9a10dd",
"assets/images/discovery/butt%2520workout.webp": "1fba56b3f55f0fb1c591d6c98143d2b6",
"assets/images/discovery/chest%2520and%2520biceps.webp": "e13e306aa9cd8cc3a1476c487f3521af",
"assets/images/discovery/home%2520boy.webp": "a1f5fe63dbb01772f38e06d9f5de8067",
"assets/images/discovery/home%2520girl.webp": "98fe1b998e49358963b2c51b75569a42",
"assets/images/discovery/nutrition.webp": "e282a24f6de53bd1f75c184928356b1c",
"assets/images/discovery/quick%2520pump.webp": "e87e85e22470b7f5b2514359573cfa41",
"assets/images/discovery/skin%2520care.webp": "8a318e56c60e66213d25c748893e897b",
"assets/images/discovery/weight%2520gain.webp": "f3c8e0269068f5af9145d4dc1f96e76f",
"assets/images/First%2520three/full%2520body/boy.webp": "e223454798fb0236c7bbc331d69febda",
"assets/images/First%2520three/full%2520body/girl.webp": "c4028f07830b5e594a3a7b9280f3daf2",
"assets/images/First%2520three/weight%2520loss/boy.webp": "c0ae67056eb241e274e94b83ba2e4fa7",
"assets/images/First%2520three/weight%2520loss/girl.webp": "10a9ec17525c7fa516411d945234a255",
"assets/images/gym/gym.webp": "dc37419fdfb68ed0bad9aa105eb6ac4f",
"assets/images/home%2520workout/boy/abs.webp": "befbe3969b7fcb65587602f9526f2785",
"assets/images/home%2520workout/boy/arm.webp": "e7c00385d3887611e21589ba381e7e5b",
"assets/images/home%2520workout/boy/back%2520and%2520shoulder.webp": "29f5552fd39c407eadceecf86f1e8efe",
"assets/images/home%2520workout/boy/chest.webp": "1bb388b6da6166ffbfc6b51592cf0a01",
"assets/images/home%2520workout/boy/leg.webp": "a25806c433debaeeb89cfd9b60266d1b",
"assets/images/home%2520workout/boy.webp": "39fb9d89d4b29d2fa721afd99cfc0a42",
"assets/images/home%2520workout/girl/abs.webp": "42148b7115492a0c02a0ab8e88955f93",
"assets/images/home%2520workout/girl/arm.webp": "35043cb11efba7447603d3892166220c",
"assets/images/home%2520workout/girl/back%2520and%2520shoulder.webp": "96c53dbb64b3d92b0c7b09a0817431c6",
"assets/images/home%2520workout/girl/chest.webp": "40eeaf0a2bfa1410caaf6bf9e49174a9",
"assets/images/home%2520workout/girl/leg.webp": "17a3ea4ab4a733f6148479d9ea03a7cd",
"assets/images/home%2520workout/girl.webp": "be71b1fae9b6a3376827da7bd049e305",
"assets/images/intro/intro%25201.webp": "f15ca9477c5e93b58f12194aef27c216",
"assets/images/intro/intro%25202.webp": "1a3ef46bd286d7e5f6c71adf2d88cd0f",
"assets/images/intro/intro%25203.webp": "a840ba9b8a70a19430c27cced6c89ecc",
"assets/images/logo.png": "034e1c31308bc27f9d06437909d8339a",
"assets/images/starting/1.jpg": "ed4bc5a3ec0a593c32c579ab1ed15182",
"assets/images/starting/2.jpg": "5aca6a2bc8639f1e77dee2faf8338376",
"assets/images/workouts/archer-push-up.png": "c8f672f46482e6b6a4c809e02a7efe75",
"assets/images/workouts/arm-circles.jpg": "04ce795b98b797884bc973c09cdd00cd",
"assets/images/workouts/Bent-Over-Dumbbell-Row.jpg": "3bb3113ac0e8099a7aa26425f0c29ab3",
"assets/images/workouts/Biceps-Leg-Concentration-Curl.png": "c8f672f46482e6b6a4c809e02a7efe75",
"assets/images/workouts/box-jumps.jpg": "d7d859d009af9f4bf9d30648c359c975",
"assets/images/workouts/Bulgarian-Jump-Squat.jpg": "39df9824506a427cc0b19f45b5645630",
"assets/images/workouts/Burpees.jpg": "f5f45000dc35a504f0a2c8e342b46862",
"assets/images/workouts/butt-kicks.png": "c8f672f46482e6b6a4c809e02a7efe75",
"assets/images/workouts/calf-raises.jpg": "46f83b2fcb93ade50461899682dbb9f5",
"assets/images/workouts/Clapping%2520Push-Ups.jpg": "80f0fe5267ad05bcc1059d8d211adad4",
"assets/images/workouts/Close-Grip-Dumbbell-Press.jpg": "cc41a9b10532e6f3107b0d9a1251bb4e",
"assets/images/workouts/concentration-curl.jpg": "fbbb0c1321ae9fc9ddf9c07557cef8dc",
"assets/images/workouts/Cossack-Squat.jpg": "a01a13f468066259633c82e1b1ac160d",
"assets/images/workouts/Cross%2520Crunch.jpg": "37ff6b61f61ac629f4559406354c1d8d",
"assets/images/workouts/crunches.jpg": "c6351f78906306a19f854ed67bf186a5",
"assets/images/workouts/db-bench-press.jpg": "54c12132f116056771ca0d7ace4eeef9",
"assets/images/workouts/db-bicep-curl.jpg": "0df5ab81676b387071d067cdb7506f25",
"assets/images/workouts/db-pullover.png": "c8f672f46482e6b6a4c809e02a7efe75",
"assets/images/workouts/db-shoulder.jpg": "96ec5c3346d31622c2808552a49ce9ad",
"assets/images/workouts/db-triceps-ext.jpg": "29adf304066118eb4e7bbe7d608a2e64",
"assets/images/workouts/decline-push-up.jpg": "13d17bf1c7a56e523cfa073a84736862",
"assets/images/workouts/diamond-push-up.jpg": "df744a67cf5a460c78f66864a84946e7",
"assets/images/workouts/Dumbbell-Fly.jpg": "ceb76bfa83708d3fbb328070ee63ae61",
"assets/images/workouts/Dumbbell-High-Curl.png": "c8f672f46482e6b6a4c809e02a7efe75",
"assets/images/workouts/gdonkey_kicks.jpg": "a74f16117127fe2e315ffe8d1cddbf49",
"assets/images/workouts/gglute_bridge.jpg": "e205e2f8dc5047dd765f7c780608470b",
"assets/images/workouts/glute-bridge.jpg": "1b3054b934251147dafa658ca056d60f",
"assets/images/workouts/gside_lunges.jpg": "2aa55280825ce675ff64ef833dc254e3",
"assets/images/workouts/gsquats.jpg": "7db7ebd8edbc2bab92effd0d0091e8a9",
"assets/images/workouts/hammer-curl.jpg": "8d508005c195550058902627b1c708ef",
"assets/images/workouts/handstand-push-up.jpg": "6332547f3ca2e6895bc2a981f2bf9534",
"assets/images/workouts/high-knees.jpg": "73473bc8960d121966239883541d22b7",
"assets/images/workouts/hollow%2520hold.png": "c8f672f46482e6b6a4c809e02a7efe75",
"assets/images/workouts/incline-push-up.jpg": "c0d9cf8a49e8719e46a8d27062991dd7",
"assets/images/workouts/jog-in-place.jpg": "73912b13f221af3ebfd2bc7fc129c37a",
"assets/images/workouts/jump-squats.jpg": "0e0e8b57eb2667e4d58adb069bd1cc35",
"assets/images/workouts/jumping-jack.jpg": "b1f95371daf004ab3728f8dc930f4beb",
"assets/images/workouts/knee-push-up.png": "c8f672f46482e6b6a4c809e02a7efe75",
"assets/images/workouts/lean-planche.jpg": "d480e41b60100dd1d0b82048e527bb59",
"assets/images/workouts/lunges.jpg": "da3a16f887e46596842af9086d600fa1",
"assets/images/workouts/Modified-Hindu-Push-up.jpg": "e5c3adab06c2aff877fbf7daa65b9e04",
"assets/images/workouts/pike-push-up.jpg": "7f5a1cb3db68adc2c5c2ca623c05802e",
"assets/images/workouts/pistol-squats.png": "c8f672f46482e6b6a4c809e02a7efe75",
"assets/images/workouts/plank.jpg": "763db0deb2a3ed08e1c8f51cb41b5458",
"assets/images/workouts/power-lunge.jpg": "a3e68d455b6910efc702b2472cfcea48",
"assets/images/workouts/pseudo-planche-push-up.jpg": "1ab8d0899f724572de10548ef6f1638f",
"assets/images/workouts/push-up.jpg": "1ad0c66233165984e89fb3a384a01ace",
"assets/images/workouts/Reverse-Lunge-Knee.jpg": "eb50b65e83a1eb006ba0426dfb4bacfc",
"assets/images/workouts/russian-twists.png": "c8f672f46482e6b6a4c809e02a7efe75",
"assets/images/workouts/shadow-boxing.jpg": "7c4192d3a4489af7c826e37f83872249",
"assets/images/workouts/side-plank.jpg": "0b9735f72669e49414041f4c249f09dc",
"assets/images/workouts/Skip-Jump-Rope.jpg": "924b145b5007f0d867ab397b836da42d",
"assets/images/workouts/squats.jpg": "8206c0b2163280690d02d0e102a42631",
"assets/images/workouts/triceps-dips.jpg": "49804cd3769bb9ec09a532a09afcd8a7",
"assets/images/workouts/Tuck-Crunch.jpg": "d1bbadfed4f0096158f271695207ae86",
"assets/images/workouts/wall-push-up.jpg": "243588777380b8bb9e889107e3eb6fd8",
"assets/images/workouts/wall-sit.jpg": "cdb9cd927f8702a31eed78ec57cdbc43",
"assets/images/workouts/wide-push-up.jpg": "75d4685c92ad8e6a4ce3bb63176e5540",
"assets/NOTICES": "8bd0d911b11cb4cc9e270c8e4a2535d7",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "739d127146e9a8593e6a59a6c01cf045",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "644b504fd9f4e5d94575cba1ab4f8ce8",
"icons/Icon-192.png": "eb90eb00b1dceca9a88451aed4dc9642",
"icons/Icon-512.png": "3219817fe173dc0e27ae353328806585",
"icons/Icon-maskable-192.png": "eb90eb00b1dceca9a88451aed4dc9642",
"icons/Icon-maskable-512.png": "3219817fe173dc0e27ae353328806585",
"index.html": "dcdd68bedca7a0327ddefabedf9506c7",
"/": "dcdd68bedca7a0327ddefabedf9506c7",
"main.dart.js": "3cce30d9f63450d5b19183348f7690ca",
"manifest.json": "ede2762cc5d9dc1d2d3fdcd729a3410f",
"splash/img/dark-1x.png": "e1980ada09b7962ca5405c235e1170f7",
"splash/img/dark-2x.png": "ece305790218df806815951ade8f31a6",
"splash/img/dark-3x.png": "09001e25246f49ad292e39fc1cc73cc8",
"splash/img/dark-4x.png": "24a76a14d1b5382aaf0f06e86bd0d5b2",
"splash/img/light-1x.png": "e1980ada09b7962ca5405c235e1170f7",
"splash/img/light-2x.png": "ece305790218df806815951ade8f31a6",
"splash/img/light-3x.png": "09001e25246f49ad292e39fc1cc73cc8",
"splash/img/light-4x.png": "24a76a14d1b5382aaf0f06e86bd0d5b2",
"version.json": "fde96cb896097e538878ed3f1e480f71"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
