import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> surahNames = [
  'الفاتحة','البقرة','آل عمران','النساء','المائدة','الأنعام','الأعراف','الأنفال','التوبة','يونس',
  'هود','يوسف','الرعد','إبراهيم','الحجر','النحل','الإسراء','الكهف','مريم','طه',
  'الأنبياء','الحج','المؤمنون','النور','الفرقان','الشعراء','النمل','القصص','العنكبوت','الروم',
  'لقمان','السجدة','الأحزاب','سبأ','فاطر','يس','الصافات','ص','الزمر','غافر',
  'فصلت','الشورى','الزخرف','الدخان','الجاثية','الأحقاف','محمد','الفتح','الحجرات','ق',
  'الذاريات','الطور','النجم','القمر','الرحمن','الواقعة','الحديد','المجادلة','الحشر','الممتحنة',
  'الصف','الجمعة','المنافقون','التغابن','الطلاق','التحريم','الملك','القلم','الحاقة','المعارج',
  'نوح','الجن','المزمل','المدثر','القيامة','الإنسان','المرسلات','النبأ','النازعات','عبس',
  'التكوير','الانفطار','المطففين','الانشقاق','البروج','الطارق','الأعلى','الغاشية','الفجر','البلد',
  'الشمس','الليل','الضحى','الشرح','التين','العلق','القدر','البينة','الزلزلة','العاديات',
  'القارعة','التكاثر','العصر','الهمزة','الفيل','قريش','الماعون','الكوثر','الكافرون','النصر',
  'المسد','الإخلاص','الفلق','الناس'
];

String surahUrl(int n) =>
    'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$n.mp3';
String surahUrlAlt(int n) =>
    'https://server8.mp3quran.net/afs/${n.toString().padLeft(3, '0')}.mp3';

void main() => runApp(const PrayerApp());

class PrayerApp extends StatelessWidget {
  const PrayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'المصلي المتحرك',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF071A1A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF26C6DA),
          brightness: Brightness.dark,
        ),
      ),
      home: const PrayerScreen(),
    );
  }
}

const List<Offset> qiyam = [
  Offset(300,225), Offset(300,272), Offset(300,280),
  Offset(286,400), Offset(314,400), Offset(284,545), Offset(316,545),
  Offset(280,680), Offset(320,680), Offset(250,335), Offset(350,335),
  Offset(292,342), Offset(308,347)];
const List<Offset> ruku = [
  Offset(300,298), Offset(300,340), Offset(300,348),
  Offset(286,440), Offset(314,440), Offset(284,565), Offset(316,565),
  Offset(280,680), Offset(320,680), Offset(252,405), Offset(348,405),
  Offset(284,552), Offset(316,552)];
const List<Offset> sujud = [
  Offset(452,585), Offset(415,580), Offset(402,570),
  Offset(286,585), Offset(314,585), Offset(282,675), Offset(318,675),
  Offset(282,612), Offset(318,612), Offset(368,628), Offset(450,628),
  Offset(392,672), Offset(432,672)];
const List<Offset> jalsa = [
  Offset(300,425), Offset(300,472), Offset(300,480),
  Offset(286,600), Offset(314,600), Offset(258,580), Offset(342,580),
  Offset(248,660), Offset(352,660), Offset(250,545), Offset(350,545),
  Offset(260,575), Offset(340,575)];

const List<List<Offset>> postures = [qiyam, ruku, sujud, jalsa];
const postureNames = ['قيام', 'ركوع', 'سجود', 'جلوس'];

class PrayerPainter extends CustomPainter {
  final double t;
  final List<List<double>> phases;
  final double total;
  PrayerPainter(this.t, this.phases, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    double secs = t * total;
    int idx = 0;
    double acc = 0;
    while (idx < phases.length - 1 && secs > acc + phases[idx][2]) {
      acc += phases[idx][2];
      idx++;
    }
    double local = ((secs - acc) / phases[idx][2]).clamp(0.0, 1.0);
    double p = local * local * (3 - 2 * local);
    int from = phases[idx][0].toInt(), to = phases[idx][1].toInt();

    Offset j(int i) =>
        Offset.lerp(postures[from][i], postures[to][i], p)!;

    final bg = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      bg,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B2B26), Color(0xFF071A1A)],
        ).createShader(bg),
    );

    canvas.drawCircle(
      const Offset(300, 420), 190,
      Paint()
        ..color = const Color(0x3326C6DA)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(200, 668, 200, 40), const Radius.circular(14)),
      Paint()..color = const Color(0xFF14532D));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(212, 674, 176, 28), const Radius.circular(10)),
      Paint()..color = const Color(0xFF1E6B38));

    final limb = Paint()
      ..color = const Color(0xFFE0F7FA)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawLine(j(3), j(5), limb);
    canvas.drawLine(j(5), j(7), limb);
    canvas.drawLine(j(4), j(6), limb);
    canvas.drawLine(j(6), j(8), limb);
    canvas.drawLine(
        j(2),
        Offset((j(3).dx + j(4).dx) / 2, (j(3).dy + j(4).dy) / 2),
        limb);
    canvas.drawLine(j(2), j(9), limb);
    canvas.drawLine(j(9), j(11), limb);
    canvas.drawLine(j(2), j(10), limb);
    canvas.drawLine(j(10), j(12), limb);
    canvas.drawCircle(j(0), 24, Paint()..color = const Color(0xFFE0F7FA));
    canvas.drawCircle(
      j(0), 30,
      Paint()
        ..color = const Color(0x6626C6DA)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  @override
  bool shouldRepaint(PrayerPainter old) =>
      old.t != t || old.total != total;
}

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final AudioPlayer _player = AudioPlayer();
  bool _moving = false;
  bool _soundOn = false;
  String _surah = '';
  int _rakaat = 1;
  double _lastT = 0;

  double dQiyam = 8;
  double dRuku = 3;
  double dSjud = 4;
  double dJalsa = 3;
  double dMove = 2;

  List<List<double>> get _phases => [
    [0, 0, dQiyam],
    [0, 1, dMove],
    [1, 1, dRuku],
    [1, 2, dMove],
    [2, 2, dSjud],
    [2, 3, dMove],
    [3, 3, dJalsa],
    [3, 0, dMove],
  ];

  double get _total =>
      _phases.fold(0.0, (s, e) => s + e[2]);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 26));
    _ctrl.addListener(() {
      if (_ctrl.value < _lastT) setState(() => _rakaat++);
      _lastT = _ctrl.value;
    });
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      dQiyam = p.getDouble('dQiyam') ?? 8;
      dRuku = p.getDouble('dRuku') ?? 3;
      dSjud = p.getDouble('dSjud') ?? 4;
      dJalsa = p.getDouble('dJalsa') ?? 3;
      dMove = p.getDouble('dMove') ?? 2;
    });
    _applyDuration();
  }

  Future<void> _saveSettings() async {
    final p = await SharedPreferences.getInstance();
    p.setDouble('dQiyam', dQiyam);
    p.setDouble('dRuku', dRuku);
    p.setDouble('dSjud', dSjud);
    p.setDouble('dJalsa', dJalsa);
    p.setDouble('dMove', dMove);
  }

  void _applyDuration() {
    _ctrl.duration =
        Duration(milliseconds: (_total * 1000).round());
    if (_moving) _ctrl.repeat();
  }

  void _toggleMotion() {
    setState(() => _moving = !_moving);
    if (_moving) {
      _ctrl.repeat();
    } else {
      _ctrl.stop();
      _player.pause();
    }
  }

  Future<void> _pickSurah() async {
    final n = await showDialog<int>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SimpleDialog(
          title: const Text('اختر السورة',
              style: TextStyle(fontSize: 20)),
          children: [
            SizedBox(
              width: 320, height: 420,
              child: ListView.builder(
                itemCount: 114,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  leading: Text('${i + 1}'),
                  title: Text(surahNames[i],
                      style: const TextStyle(fontSize: 17)),
                  onTap: () => Navigator.pop(ctx, i + 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (n != null) {
      setState(() {
        _soundOn = true;
        _surah = surahNames[n - 1];
      });
      try {
        await _player.stop();
        try {
          await _player.setUrl(surahUrl(n));
        } catch (_) {
          await _player.setUrl(surahUrlAlt(n));
        }
        if (_moving) await _player.play();
      } catch (_) {}
    }
  }

  void _toggleSound() {
    if (_soundOn) {
      setState(() => _soundOn = false);
      _player.pause();
    } else {
      _pickSurah();
    }
  }

  String get _postureLabel {
    double secs = _ctrl.value * _total;
    int idx = 0;
    double acc = 0;
    while (idx < _phases.length - 1 && secs > acc + _phases[idx][2]) {
      acc += _phases[idx][2];
      idx++;
    }
    return postureNames[_phases[idx][1].toInt()];
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('ضبط المدد',
                style: TextStyle(fontSize: 21)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _durRow(setD, 'القيام', 'dQiyam', 3, 60),
                  _durRow(setD, 'الركوع', 'dRuku', 2, 20),
                  _durRow(setD, 'السجود', 'dSjud', 2, 30),
                  _durRow(setD, 'الجلوس', 'dJalsa', 2, 20),
                  _durRow(setD, 'الانتقال', 'dMove', 1, 6),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  _applyDuration();
                  _saveSettings();
                  Navigator.pop(ctx);
                },
                child: const Text('حفظ',
                    style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _durRow(StateSetter setD, String label, String key,
      double min, double max) {
    double val = key == 'dQiyam' ? dQiyam
        : key == 'dRuku' ? dRuku
        : key == 'dSjud' ? dSjud
        : key == 'dJalsa' ? dJalsa : dMove;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontSize: 17)),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: val > min
                ? () => setD(() => _setDur(key, val - 1))
                : null,
          ),
          Text('${val.round()} ث',
              style: const TextStyle(fontSize: 18)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: val < max
                ? () => setD(() => _setDur(key, val + 1))
                : null,
          ),
        ],
      ),
    );
  }

  void _setDur(String key, double v) {
    if (key == 'dQiyam') dQiyam = v;
    if (key == 'dRuku') dRuku = v;
    if (key == 'dSjud') dSjud = v;
    if (key == 'dJalsa') dJalsa = v;
    if (key == 'dMove') dMove = v;
  }

  @override
  void dispose() {
    _player.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المصلي المتحرك',
              style: TextStyle(fontSize: 22)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, size: 28),
              onPressed: _showSettings,
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 6),
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Text(
                _moving ? 'الوضعية: $_postureLabel' : 'متوقف',
                style: const TextStyle(
                    fontSize: 20, color: Colors.tealAccent),
              ),
            ),
            Text('الركعة: $_rakaat',
                style: const TextStyle(
                    fontSize: 18, color: Colors.white70)),
            if (_soundOn)
              Text(_surah,
                  style: const TextStyle(
                      fontSize: 16, color: Colors.white70)),
            Expanded(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => CustomPaint(
                  painter: PrayerPainter(
                      _ctrl.value, _phases, _total),
                  size: Size.infinite,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 14),
                      backgroundColor:
                          _moving ? Colors.redAccent : Colors.teal,
                    ),
                    onPressed: _toggleMotion,
                    icon: Icon(
                        _moving ? Icons.pause : Icons.play_arrow,
                        size: 28),
                    label: Text(
                      _moving ? 'إيقاف' : 'ابدأ الصلاة',
                      style: const TextStyle(fontSize: 19),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                    ),
                    onPressed: _toggleSound,
                    icon: Icon(
                        _soundOn ? Icons.volume_up : Icons.volume_off,
                        size: 26),
                    label: Text(
                        _soundOn ? 'كتم الصوت' : 'صوت القارئ',
                        style: const TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
