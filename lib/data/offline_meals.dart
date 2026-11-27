import '../models/meal.dart';

/// Menu bawaan, dipakai kalau server tidak bisa dihubungi.
const List<Meal> offlineMeals = [
  Meal(
    id: 'lokal-1',
    name: 'Nasi goreng kampung',
    category: 'Nasi',
    area: 'Indonesia',
    ingredients: [
      Ingredient('Nasi putih (sebaiknya dingin)', '3 piring'),
      Ingredient('Bawang merah', '4 siung'),
      Ingredient('Bawang putih', '2 siung'),
      Ingredient('Cabai merah', '3 buah'),
      Ingredient('Ikan teri', '2 sdm'),
      Ingredient('Telur', '2 butir'),
      Ingredient('Kecap manis', '2 sdm'),
      Ingredient('Minyak goreng', '3 sdm'),
      Ingredient('Garam', 'secukupnya'),
    ],
    instructions:
        'Haluskan bawang merah, bawang putih, dan cabai.\n'
        'Panaskan minyak, tumis bumbu halus dan ikan teri sampai harum.\n'
        'Geser bumbu ke pinggir wajan, masukkan telur lalu orak-arik.\n'
        'Masukkan nasi, kecap manis, dan garam. Aduk rata dengan api besar selama 3 sampai 4 menit.\n'
        'Sajikan hangat dengan kerupuk dan irisan mentimun.',
  ),
  Meal(
    id: 'lokal-2',
    name: 'Soto ayam',
    category: 'Sup',
    area: 'Indonesia',
    ingredients: [
      Ingredient('Ayam', '500 g'),
      Ingredient('Air', '1,5 liter'),
      Ingredient('Serai', '2 batang'),
      Ingredient('Daun jeruk', '3 lembar'),
      Ingredient('Bawang putih', '4 siung'),
      Ingredient('Kunyit', '2 cm'),
      Ingredient('Jahe', '2 cm'),
      Ingredient('Soun, rebus', '1 genggam'),
      Ingredient('Telur rebus', '2 butir'),
      Ingredient('Garam', '1 sdt'),
    ],
    instructions:
        'Rebus ayam bersama serai dan daun jeruk sampai matang. Angkat ayam, suwir, sisihkan kaldunya.\n'
        'Haluskan bawang putih, kunyit, dan jahe, lalu tumis sampai harum.\n'
        'Masukkan tumisan ke dalam kaldu, tambahkan garam, masak 15 menit.\n'
        'Susun soun, suwiran ayam, dan telur dalam mangkuk, lalu siram kuah panas.\n'
        'Beri taburan bawang goreng dan perasan jeruk nipis.',
  ),
  Meal(
    id: 'lokal-3',
    name: 'Gado-gado',
    category: 'Sayur',
    area: 'Indonesia',
    ingredients: [
      Ingredient('Kol', '100 g'),
      Ingredient('Kangkung', '1 ikat'),
      Ingredient('Tauge', '100 g'),
      Ingredient('Kentang rebus', '2 buah'),
      Ingredient('Tahu dan tempe goreng', '4 potong'),
      Ingredient('Telur rebus', '2 butir'),
      Ingredient('Kacang tanah goreng', '150 g'),
      Ingredient('Gula merah', '1 sdm'),
      Ingredient('Cabai rawit', '3 buah'),
    ],
    instructions:
        'Rebus kol, kangkung, dan tauge sebentar sampai layu. Tiriskan.\n'
        'Ulek kacang bersama cabai, gula merah, dan sedikit garam. Tambahkan air hangat sampai kental.\n'
        'Tata sayur, kentang, tahu, tempe, dan telur di piring.\n'
        'Siram dengan bumbu kacang dan sajikan dengan kerupuk.',
  ),
  Meal(
    id: 'lokal-4',
    name: 'Mie goreng',
    category: 'Mie',
    area: 'Indonesia',
    ingredients: [
      Ingredient('Mie telur', '250 g'),
      Ingredient('Ayam suwir', '100 g'),
      Ingredient('Sawi hijau', '2 batang'),
      Ingredient('Bawang putih', '3 siung'),
      Ingredient('Kecap manis', '2 sdm'),
      Ingredient('Saus tiram', '1 sdm'),
      Ingredient('Telur', '1 butir'),
      Ingredient('Minyak goreng', '2 sdm'),
    ],
    instructions:
        'Rebus mie setengah matang, tiriskan, dan beri sedikit minyak agar tidak lengket.\n'
        'Tumis bawang putih cincang, masukkan telur dan orak-arik.\n'
        'Masukkan ayam dan sawi, tumis sebentar.\n'
        'Tambahkan mie, kecap manis, dan saus tiram. Aduk rata sampai bumbu meresap.',
  ),
  Meal(
    id: 'lokal-5',
    name: 'Sate ayam bumbu kacang',
    category: 'Bakar',
    area: 'Indonesia',
    ingredients: [
      Ingredient('Dada atau paha ayam', '500 g'),
      Ingredient('Kecap manis', '3 sdm'),
      Ingredient('Bawang putih', '3 siung'),
      Ingredient('Ketumbar bubuk', '1 sdt'),
      Ingredient('Kacang tanah goreng', '100 g'),
      Ingredient('Tusuk sate', '20 buah'),
      Ingredient('Lontong', 'secukupnya'),
    ],
    instructions:
        'Potong ayam dadu kecil. Lumuri kecap, bawang putih halus, dan ketumbar. Diamkan 30 menit.\n'
        'Tusuk ayam pada tusuk sate, empat sampai lima potong per tusuk.\n'
        'Bakar di atas bara sambil dibolak-balik dan diolesi sisa marinasi sampai matang.\n'
        'Sajikan dengan bumbu kacang dan lontong.',
  ),
  Meal(
    id: 'lokal-6',
    name: 'Rendang daging',
    category: 'Daging',
    area: 'Indonesia',
    ingredients: [
      Ingredient('Daging sapi', '1 kg'),
      Ingredient('Santan kental', '1 liter'),
      Ingredient('Cabai merah giling', '150 g'),
      Ingredient('Bawang merah', '8 siung'),
      Ingredient('Bawang putih', '5 siung'),
      Ingredient('Jahe dan lengkuas', '3 cm masing-masing'),
      Ingredient('Serai', '2 batang'),
      Ingredient('Daun kunyit dan daun jeruk', '3 lembar masing-masing'),
      Ingredient('Garam', '2 sdt'),
    ],
    instructions:
        'Haluskan cabai, bawang merah, bawang putih, jahe, dan lengkuas.\n'
        'Campur bumbu halus, santan, serai, dan dedaunan dalam panci. Masak sambil diaduk sampai mendidih.\n'
        'Masukkan daging potong besar dan garam. Masak dengan api kecil sambil sesekali diaduk.\n'
        'Lanjutkan 3 sampai 4 jam sampai kuah menyusut dan bumbu berminyak serta menghitam.',
  ),
];
