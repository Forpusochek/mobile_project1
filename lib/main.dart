import 'dart:async';

import 'package:flutter/material.dart';

const String nazvanieProekta = 'Второй шанс';
const String podzagolovok = 'Обмен и безвозмездная передача ненужных вещей';
const Color osnovnoyCvet = Color(0xFF2E7D5B);

const String imyaObyekta = 'вещь';
const String imyaObyektovMnozhestvo = 'Мои вещи';

// Статусы вещи. В остальном коде используются только по имени константы.
const String statusNovyy = 'ждёт хозяина';
const String statusGotov = 'передана';

// Способ передачи вещи.
const String tipDarom = 'даром';
const String tipObmen = 'обмен';

void main() {
  runApp(const Prilozhenie());
}

// ---------------------------------------------------------------------
// Данные
// ---------------------------------------------------------------------

class Polzovatel {
  final String imya;
  final String pochta;
  final String parol;
  final String telefon;
  final String gorod;

  const Polzovatel({
    required this.imya,
    required this.pochta,
    required this.parol,
    required this.telefon,
    required this.gorod,
  });
}

class Zapis {
  final int id;
  String nazvanie;
  String opisanie;
  String mesto;
  String tip;
  String status;

  Zapis({
    required this.id,
    required this.nazvanie,
    required this.opisanie,
    required this.mesto,
    required this.tip,
    this.status = statusNovyy,
  });
}

class Hranilishe {
  static final List<Polzovatel> _polzovateli = [];
  static final Map<String, List<Zapis>> _zapisiPoPochte = {};
  static Polzovatel? tekushiy;
  static int _sleduyushiyId = 1;

  // У каждого пользователя свой список вещей.
  static List<Zapis> get zapisi =>
      _zapisiPoPochte.putIfAbsent(tekushiy!.pochta, () => []);

  static bool zaregistrirovat(Polzovatel polzovatel) {
    final zanyata = _polzovateli.any((p) => p.pochta == polzovatel.pochta);
    if (zanyata) return false;
    _polzovateli.add(polzovatel);
    return true;
  }

  static bool voyti(String pochta, String parol) {
    for (var p in _polzovateli) {
      if (p.pochta == pochta && p.parol == parol) {
        tekushiy = p;
        return true;
      }
    }
    return false;
  }

  static void vyyti() {
    tekushiy = null;
  }

  static void dobavitZapis(
      String nazvanie, String opisanie, String mesto, String tip) {
    zapisi.add(Zapis(
      id: _sleduyushiyId,
      nazvanie: nazvanie,
      opisanie: opisanie,
      mesto: mesto,
      tip: tip,
    ));
    _sleduyushiyId = _sleduyushiyId + 1;
  }

  static void pomenyatStatus(int id) {
    for (var z in zapisi) {
      if (z.id == id) {
        z.status = (z.status == statusNovyy) ? statusGotov : statusNovyy;
      }
    }
  }

  static void udalitZapis(int id) {
    zapisi.removeWhere((z) => z.id == id);
  }
}

// ---------------------------------------------------------------------
// Проверки полей
// ---------------------------------------------------------------------

final RegExp _shablonPochty = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
final RegExp _shablonTelefona = RegExp(r'^\+7\d{10}$');

String ochistitTelefon(String telefon) =>
    telefon.replaceAll(RegExp(r'[\s()-]'), '');

String? proveritPochtu(String? znachenie) {
  final pochta = (znachenie ?? '').trim();
  if (pochta.isEmpty) return 'Введите почту';
  if (!_shablonPochty.hasMatch(pochta)) {
    return 'Почта должна быть вида name@mail.kz';
  }
  return null;
}

String? proveritTelefon(String? znachenie) {
  final telefon = ochistitTelefon(znachenie ?? '');
  if (telefon.isEmpty) return 'Введите номер телефона';
  if (!_shablonTelefona.hasMatch(telefon)) {
    return 'Номер в формате +7 777 123 45 67';
  }
  return null;
}

// ---------------------------------------------------------------------
// Приложение
// ---------------------------------------------------------------------

class Prilozhenie extends StatelessWidget {
  const Prilozhenie({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: nazvanieProekta,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: osnovnoyCvet),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const ZapuskEkran(),
    );
  }
}

// ---------------------------------------------------------------------
// Экран запуска
// ---------------------------------------------------------------------

class ZapuskEkran extends StatefulWidget {
  const ZapuskEkran({super.key});

  @override
  State<ZapuskEkran> createState() => _ZapuskEkranState();
}

class _ZapuskEkranState extends State<ZapuskEkran> {
  Timer? _taymer;

  @override
  void initState() {
    super.initState();
    _taymer = Timer(const Duration(seconds: 2), _dalshe);
  }

  void _dalshe() {
    final Widget sleduyushiy =
        Hranilishe.tekushiy == null ? const VhodEkran() : const GlavnyyEkran();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => sleduyushiy),
    );
  }

  @override
  void dispose() {
    _taymer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: osnovnoyCvet,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.volunteer_activism, size: 96, color: Colors.white),
              SizedBox(height: 24),
              Text(
                nazvanieProekta,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                podzagolovok,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Вход
// ---------------------------------------------------------------------

class VhodEkran extends StatefulWidget {
  const VhodEkran({super.key});

  @override
  State<VhodEkran> createState() => _VhodEkranState();
}

class _VhodEkranState extends State<VhodEkran> {
  final _formKey = GlobalKey<FormState>();
  final _pochtaController = TextEditingController();
  final _parolController = TextEditingController();
  bool _skrytParol = true;

  @override
  void dispose() {
    _pochtaController.dispose();
    _parolController.dispose();
    super.dispose();
  }

  void _voyti() {
    if (!_formKey.currentState!.validate()) return;

    final uspeh = Hranilishe.voyti(
      _pochtaController.text.trim().toLowerCase(),
      _parolController.text,
    );
    if (!uspeh) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неверная почта или пароль')),
      );
      return;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const GlavnyyEkran()),
      (route) => false,
    );
  }

  Future<void> _otkrytRegistraciyu() async {
    final pochta = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const RegistraciyaEkran()),
    );
    if (pochta == null || !mounted) return;
    _pochtaController.text = pochta;
    _parolController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Аккаунт создан, теперь войдите')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.volunteer_activism,
                      size: 64, color: osnovnoyCvet),
                  const SizedBox(height: 12),
                  const Text(
                    nazvanieProekta,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Войдите, чтобы отдавать и обменивать вещи',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _pochtaController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Почта',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: proveritPochtu,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _parolController,
                    obscureText: _skrytParol,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_skrytParol
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _skrytParol = !_skrytParol),
                      ),
                    ),
                    validator: (znachenie) => (znachenie ?? '').isEmpty
                        ? 'Введите пароль'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _voyti,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Войти'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _otkrytRegistraciyu,
                    child: const Text('Нет аккаунта? Зарегистрироваться'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Регистрация
// ---------------------------------------------------------------------

class RegistraciyaEkran extends StatefulWidget {
  const RegistraciyaEkran({super.key});

  @override
  State<RegistraciyaEkran> createState() => _RegistraciyaEkranState();
}

class _RegistraciyaEkranState extends State<RegistraciyaEkran> {
  final _formKey = GlobalKey<FormState>();
  final _imyaController = TextEditingController();
  final _pochtaController = TextEditingController();
  final _telefonController = TextEditingController();
  final _gorodController = TextEditingController();
  final _parolController = TextEditingController();
  final _povtorController = TextEditingController();

  @override
  void dispose() {
    _imyaController.dispose();
    _pochtaController.dispose();
    _telefonController.dispose();
    _gorodController.dispose();
    _parolController.dispose();
    _povtorController.dispose();
    super.dispose();
  }

  void _zaregistrirovatsya() {
    if (!_formKey.currentState!.validate()) return;

    final pochta = _pochtaController.text.trim().toLowerCase();
    final uspeh = Hranilishe.zaregistrirovat(Polzovatel(
      imya: _imyaController.text.trim(),
      pochta: pochta,
      parol: _parolController.text,
      telefon: ochistitTelefon(_telefonController.text),
      gorod: _gorodController.text.trim(),
    ));

    if (!uspeh) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Эта почта уже зарегистрирована')),
      );
      return;
    }
    Navigator.pop(context, pochta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Телефон и город увидят только те, с кем вы договариваетесь '
                  'о передаче вещи.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _imyaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Имя',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (znachenie) => (znachenie ?? '').trim().isEmpty
                      ? 'Введите имя'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pochtaController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Почта',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: proveritPochtu,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Телефон для связи',
                    hintText: '+7 777 123 45 67',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: proveritTelefon,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gorodController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Город',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  validator: (znachenie) => (znachenie ?? '').trim().isEmpty
                      ? 'Укажите город, где будете передавать вещи'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parolController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (znachenie) {
                    final parol = znachenie ?? '';
                    if (parol.isEmpty) return 'Придумайте пароль';
                    if (parol.length < 6) return 'Пароль не короче 6 символов';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _povtorController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Повторите пароль',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (znachenie) => znachenie != _parolController.text
                      ? 'Пароли не совпадают'
                      : null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _zaregistrirovatsya,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Создать аккаунт'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Основной экран с нижней навигацией
// ---------------------------------------------------------------------

class GlavnyyEkran extends StatefulWidget {
  const GlavnyyEkran({super.key});

  @override
  State<GlavnyyEkran> createState() => _GlavnyyEkranState();
}

class _GlavnyyEkranState extends State<GlavnyyEkran> {
  int _indeks = 0;

  static const _zagolovki = ['Обзор', imyaObyektovMnozhestvo, 'Профиль'];

  void _pereyti(int indeks) {
    setState(() => _indeks = indeks);
  }

  @override
  Widget build(BuildContext context) {
    final Widget razdel = switch (_indeks) {
      0 => GlavnayaStranica(otkrytVeshi: () => _pereyti(1)),
      1 => const OsnovnoyRazdel(),
      _ => const ProfilStranica(),
    };

    return Scaffold(
      appBar: AppBar(title: Text(_zagolovki[_indeks])),
      body: razdel,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indeks,
        onTap: _pereyti,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Обзор',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: imyaObyektovMnozhestvo,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Главная страница
// ---------------------------------------------------------------------

class GlavnayaStranica extends StatelessWidget {
  final VoidCallback otkrytVeshi;

  const GlavnayaStranica({super.key, required this.otkrytVeshi});

  @override
  Widget build(BuildContext context) {
    final polzovatel = Hranilishe.tekushiy!;
    final vsego = Hranilishe.zapisi.length;
    final peredano =
        Hranilishe.zapisi.where((z) => z.status == statusGotov).length;
    final zhdut = vsego - peredano;

    final String podskazka;
    if (vsego == 0) {
      podskazka = 'Начните с одной вещи: откройте «$imyaObyektovMnozhestvo», '
          'нажмите плюс и укажите, где её можно забрать.';
    } else if (zhdut > 0) {
      podskazka = 'Когда вещь заберут, нажмите на неё в списке, '
          'и она отметится как переданная.';
    } else {
      podskazka = 'Все ваши вещи нашли новых хозяев. '
          'Если дома есть что-то ещё ненужное, добавьте это.';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Здравствуйте, ${polzovatel.imya}!',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Выкладывайте вещи, которые вам больше не нужны, и отдавайте их '
          'даром или меняйте на то, что пригодится. Город: ${polzovatel.gorod}.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _Plitka(
                znachok: Icons.inventory_2_outlined,
                chislo: vsego,
                podpis: 'Всего вещей',
              ),
            ),
            Expanded(
              child: _Plitka(
                znachok: Icons.hourglass_bottom,
                chislo: zhdut,
                podpis: 'Ждут хозяина',
              ),
            ),
            Expanded(
              child: _Plitka(
                znachok: Icons.handshake_outlined,
                chislo: peredano,
                podpis: 'Передано',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline),
                    const SizedBox(width: 12),
                    Expanded(child: Text(podskazka)),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: otkrytVeshi,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Перейти к вещам'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Как это работает',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const _Shag(
          nomer: 1,
          tekst: 'Добавьте вещь: что это, в каком она состоянии, '
              'отдаёте даром или хотите обменять.',
        ),
        const _Shag(
          nomer: 2,
          tekst: 'Укажите, где её можно забрать. '
              'С вами свяжутся по телефону из профиля.',
        ),
        const _Shag(
          nomer: 3,
          tekst: 'После встречи отметьте вещь переданной. '
              'Счётчики на этой странице обновятся.',
        ),
      ],
    );
  }
}

class _Plitka extends StatelessWidget {
  final IconData znachok;
  final int chislo;
  final String podpis;

  const _Plitka({
    required this.znachok,
    required this.chislo,
    required this.podpis,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(znachok, color: osnovnoyCvet),
            const SizedBox(height: 8),
            Text(
              '$chislo',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              podpis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shag extends StatelessWidget {
  final int nomer;
  final String tekst;

  const _Shag({required this.nomer, required this.tekst});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: osnovnoyCvet,
        child: Text(
          '$nomer',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
      title: Text(tekst, style: const TextStyle(fontSize: 14)),
    );
  }
}

// ---------------------------------------------------------------------
// Основной раздел: список вещей пользователя
// ---------------------------------------------------------------------

class OsnovnoyRazdel extends StatefulWidget {
  const OsnovnoyRazdel({super.key});

  @override
  State<OsnovnoyRazdel> createState() => _OsnovnoyRazdelState();
}

class _OsnovnoyRazdelState extends State<OsnovnoyRazdel> {
  void _otkrytFormu() {
    final formKey = GlobalKey<FormState>();
    final nazvanieController = TextEditingController();
    final opisanieController = TextEditingController();
    final mestoController = TextEditingController();
    String tip = tipDarom;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Добавить $imyaObyekta'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nazvanieController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Что отдаёте',
                          hintText: 'Детская коляска',
                        ),
                        validator: (znachenie) =>
                            (znachenie ?? '').trim().isEmpty
                                ? 'Напишите, какую вещь отдаёте'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: opisanieController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Состояние, размер',
                          hintText: 'Б/у, без поломок',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: mestoController,
                        decoration: const InputDecoration(
                          labelText: 'Где забрать',
                          hintText: 'Район, улица или ориентир',
                        ),
                        validator: (znachenie) =>
                            (znachenie ?? '').trim().isEmpty
                                ? 'Укажите, где можно забрать вещь'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Как передаёте'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Отдам даром'),
                            selected: tip == tipDarom,
                            onSelected: (_) =>
                                setDialogState(() => tip = tipDarom),
                          ),
                          ChoiceChip(
                            label: const Text('Обменяю'),
                            selected: tip == tipObmen,
                            onSelected: (_) =>
                                setDialogState(() => tip = tipObmen),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Hranilishe.dobavitZapis(
                      nazvanieController.text.trim(),
                      opisanieController.text.trim(),
                      mestoController.text.trim(),
                      tip,
                    );
                    Navigator.pop(dialogContext);
                    setState(() {});
                  },
                  child: const Text('Добавить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final zapisi = Hranilishe.zapisi;

    return Scaffold(
      body: zapisi.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.checkroom_outlined,
                        size: 72, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Вы ещё ничего не отдаёте',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Нажмите плюс и добавьте вещь, которая лежит без дела: '
                      'одежду, книги, игрушки, технику',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 6, bottom: 88),
              itemCount: zapisi.length,
              itemBuilder: (context, indeks) {
                final zapis = zapisi[indeks];
                final gotov = zapis.status == statusGotov;
                final tipTekst =
                    zapis.tip == tipDarom ? 'Отдаю даром' : 'Меняю';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      gotov ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: gotov ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      zapis.nazvanie,
                      style: TextStyle(
                        decoration: gotov ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (zapis.opisanie.isNotEmpty)
                          Text(
                            zapis.opisanie,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text('$tipTekst · ${zapis.mesto}'),
                        Text(
                          zapis.status,
                          style: TextStyle(
                            color: gotov ? Colors.green : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Удалить',
                      onPressed: () {
                        setState(() {
                          Hranilishe.udalitZapis(zapis.id);
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        Hranilishe.pomenyatStatus(zapis.id);
                      });
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _otkrytFormu,
        tooltip: 'Добавить $imyaObyekta',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Профиль
// ---------------------------------------------------------------------

class ProfilStranica extends StatelessWidget {
  const ProfilStranica({super.key});

  void _vyyti(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Выход'),
          content: const Text(
            'Выйти из аккаунта? Ваши вещи останутся в списке, '
            'вы увидите их после следующего входа.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Остаться'),
            ),
            FilledButton(
              onPressed: () {
                Hranilishe.vyyti();
                Navigator.pop(dialogContext);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const VhodEkran()),
                  (route) => false,
                );
              },
              child: const Text('Выйти'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final polzovatel = Hranilishe.tekushiy!;
    final vsego = Hranilishe.zapisi.length;
    final peredano =
        Hranilishe.zapisi.where((z) => z.status == statusGotov).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: osnovnoyCvet,
            child: Text(
              polzovatel.imya.characters.first.toUpperCase(),
              style: const TextStyle(fontSize: 32, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            polzovatel.imya,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 20),
        _PoleProfilya(
          znachok: Icons.email_outlined,
          nazvanie: 'Почта',
          znachenie: polzovatel.pochta,
        ),
        _PoleProfilya(
          znachok: Icons.phone_outlined,
          nazvanie: 'Телефон для связи',
          znachenie: polzovatel.telefon,
        ),
        _PoleProfilya(
          znachok: Icons.location_city_outlined,
          nazvanie: 'Город передачи вещей',
          znachenie: polzovatel.gorod,
        ),
        _PoleProfilya(
          znachok: Icons.handshake_outlined,
          nazvanie: 'Передано вещей',
          znachenie: '$peredano из $vsego',
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => _vyyti(context),
          icon: const Icon(Icons.logout),
          label: const Text('Выйти из аккаунта'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _PoleProfilya extends StatelessWidget {
  final IconData znachok;
  final String nazvanie;
  final String znachenie;

  const _PoleProfilya({
    required this.znachok,
    required this.nazvanie,
    required this.znachenie,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(znachok, color: osnovnoyCvet),
        title: Text(nazvanie),
        subtitle: Text(znachenie, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
