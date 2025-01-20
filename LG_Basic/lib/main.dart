import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lg_basic/screens/splash_screen.dart';
import 'package:get_it/get_it.dart';
import 'services/ssh_service.dart';
import 'services/local_storage_service.dart';
import 'services/lg_setup_service.dart';
import 'services/lg_settings_service.dart';
import 'utils/storage_keys.dart';
import 'services/file_service.dart';
import 'screens/settings_screen.dart';
import 'utils/colors.dart';
import 'models/kml/kml_entity.dart';
import 'models/kml/look_at_entity.dart';


void services(){
  GetIt.I.registerLazySingleton(() => SSHService());
  GetIt.I.registerLazySingleton(() => LocalStorageService());
  GetIt.I.registerLazySingleton(() => LGSettingsService());
  GetIt.I.registerLazySingleton(() => LGService());
  GetIt.I.registerLazySingleton(() => FileService());
}


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  services();

  await GetIt.I<LocalStorageService>().loadStorage();

  GetIt.I<SSHService>().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Sets the Liquid Galaxy logos into the rig.
  void setLogos() async {
    try {
      await GetIt.I<LGService>().setLogos();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    setLogos();
    return MaterialApp(
      title: 'Basic LG APP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget{
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
  }

class _MainScreenState extends State<MainScreen> {

  LocalStorageService get _localStorageService =>
      GetIt.I<LocalStorageService>();

  LGService get _lgService => GetIt.I<LGService>();
  TextEditingController _searchController = TextEditingController();
  bool lgConnected = false;

  void checkLGConnection() {
    if (_localStorageService.hasItem(StorageKeys.lgConnection)) {
      if (_localStorageService.getItem(StorageKeys.lgConnection) ==
          "connected") {
        setState(() {
          lgConnected = true;
        });
      }
      else {
        setState(() {
          lgConnected = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LG app'),
        shadowColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded),
              splashRadius: 24,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Settings(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        color: ThemeColors.backgroundCardColor,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ThemeColors.snackBarBackgroundColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mount Everest',
                        style: TextStyle(
                          color: ThemeColors.textPrimary,
                          fontSize: 40,
                        ),
                      ),
                      Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {
                            final kml1 = KMLEntity(
                              name: '1',
                              content: """
                            <Style id="downArrowIcon">
                                <IconStyle>
                                  <Icon>
                                    <href>http://maps.google.com/mapfiles/kml/pal4/icon28.png</href>
                                  </Icon>
                                </IconStyle>
                              </Style>
                            <Placemark id="08485C44F635951B7999">
                              <name>Mount Everest</name>
                              <LookAt>
                                <longitude>86.88204920823038</longitude>
                                <latitude>27.96932348729214</latitude>
                                <altitude>7563.20412949713</altitude>
                                <heading>44.9523770778632</heading>
                                <tilt>69.9195322197025</tilt>
                                <gx:fovy>35</gx:fovy>
                                <range>21012.84421362682</range>
                                <altitudeMode>absolute</altitudeMode>
                              </LookAt>
                              <styleUrl>#downArrowIcon</styleUrl>
                              <gx:Carousel>
                              </gx:Carousel>
                              <Point>
                                <altitudeMode>relativeToGround</altitudeMode>
                                <coordinates>86.91942998562898,27.98534788699245,2000.5599129</coordinates>
                              </Point>
                            </Placemark>
                            """,
                            );
                            _lgService.sendKml(kml1);
                            _lgService.startTour('kml1');
                            final kml_1 = LookAtEntity(
                              lng: 86.88204920823038,
                              lat: 27.96932348729214,
                              range: 21012.84421362682,
                              tilt: 69.9195322197025,
                              heading: 44.9523770778632,
                              altitude: 7563.20412949713,
                              altitudeMode: 'absolute',
                            );
                            _lgService.flyTo(kml_1);
                          },
                          child: Text(
                            'Simulate',
                            style: TextStyle(
                              color: ThemeColors.textSecondary,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ThemeColors.snackBarBackgroundColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mt Kilimanjaro',
                        style: TextStyle(
                          color: ThemeColors.textPrimary,
                          fontSize: 40,
                        ),
                      ),
                      Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {
                            final kml2 = KMLEntity(
                              name: '2',
                              content: """
                            <Style id="downArrowIcon">
                            <IconStyle>
                              <Icon>
                                <href>https://maps.google.com/mapfiles/kml/pal4/icon28.png</href>
                              </Icon>
                            </IconStyle>
                          </Style>
                          <Placemark id="00CFF885D93595280764">
                            <name>Mt Kilimanjaro</name>
                            <LookAt>
                              <longitude>37.33058869775554</longitude>
                              <latitude>-3.069161505217327</latitude>
                              <altitude>4652.371721481661</altitude>
                              <heading>40.57465230826415</heading>
                              <tilt>60.08055641210188</tilt>
                              <gx:fovy>35</gx:fovy>
                              <range>17879.19124592794</range>
                              <altitudeMode>absolute</altitudeMode>
                            </LookAt>
                            <styleUrl>#downArrowIcon</styleUrl>
                            <Point>
                              <altitudeMode>relativeToGround</altitudeMode>
                              <coordinates>37.35691899966665,-3.066327993897857,999.9999999999999</coordinates>
                            </Point>
                          </Placemark>
                            """,
                            );
                            _lgService.sendKml(kml2);
                            _lgService.startTour('kml2');
                            final kml_2 = LookAtEntity(
                              lng: 37.33058869775554,
                              lat: -3.069161505217327,
                              range: 17879.19124592794,
                              tilt: 60.08055641210188,
                              heading: 40.57465230826415,
                              altitude: 4652.371721481661,
                              altitudeMode: 'absolute',
                            );
                            _lgService.flyTo(kml_2);
                          },
                          child: Text(
                            'Simulate',
                            style: TextStyle(
                              color: ThemeColors.textSecondary,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
