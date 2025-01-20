import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../screens/lg_settings.dart';
import '../services/local_storage_service.dart';
import '../utils/colors.dart';
import '../utils/snackbar.dart';
import '../services/lg_setup_service.dart';
import '../utils/storage_keys.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  bool tools=false, lgConnected=false;
  bool  _clearingKml = false, _showingLogos=false;

  LGService get _lgService => GetIt.I<LGService>();
  LocalStorageService get _localStorageService => GetIt.I<LocalStorageService>();
  final ScrollController _scrollController = ScrollController();
  bool _showTextInAppBar = false;
  late String dropDownValue;

  @override
  void initState() {
    checkLGConnection();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  Future<void> checkLGConnection() async{
    if(_localStorageService.hasItem(StorageKeys.lgConnection)){
      if(_localStorageService.getItem(StorageKeys.lgConnection)=="connected"){
        setState(() {
          lgConnected=true;
        });
      }
      else{
        setState(() {
          lgConnected=false;
        });
      }
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= 45) {
      setState(() {
        _showTextInAppBar = true;
      });
    } else {
      setState(() {
        _showTextInAppBar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeColors.backgroundCardColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: ThemeColors.textPrimary,
          leading: IconButton(icon : const Icon(Icons.arrow_back), onPressed: () { Navigator.pop(context,"pop"); },),
          title: _showTextInAppBar ? const Text('Settings',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold)) : const Text(''),
          bottom: _showTextInAppBar ? PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Colors.black12,
              height: 1,
            ),
          ) : null,
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 20, 20),
                  child: Text('Settings',overflow: TextOverflow.visible,style: TextStyle(fontWeight: FontWeight.bold,color: ThemeColors.textPrimary,fontSize: 40)),
                ),
                const SizedBox(height: 10,),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 20, 15),
                    child: _buildSection('APP SETTINGS')
                ),
                ListTile(
                  onTap: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> const LGSettings())
                    );
                    if(result=="pop"){
                      checkLGConnection();
                    }
                  },
                  title: _buildTitle('LG Connection'),
                  leading: _buildIcon(Icons.travel_explore_rounded),
                  trailing: const Icon(Icons.arrow_forward,),
                ),
                _divider(),
                ListTile(
                    onTap: (){
                      setState(() {
                        tools=!tools;
                      });
                    },
                    title: Text('LG Tools',style: TextStyle(color: ThemeColors.textPrimary,fontSize: 28,fontWeight: tools ? FontWeight.bold : FontWeight.normal),overflow: TextOverflow.visible,),
                    leading: _buildIcon(Icons.settings_input_antenna),
                    trailing: tools ?
                    Icon(Icons.keyboard_arrow_up,color: ThemeColors.primaryColor,) :
                    const Icon(Icons.keyboard_arrow_down,)
                ),
                tools ? showTools() : _divider(),
                ListTile(
                  onTap: (){
                    Navigator.pop(context,"refresh");
                  },
                  title: Text('Synchronize data',style: TextStyle(color: ThemeColors.textPrimary,fontSize: 28,fontWeight: FontWeight.normal),overflow: TextOverflow.visible,),
                  leading: _buildIcon(Icons.sync),
                ),
                _divider(),
              ],
            ),
          ),
        )
    );
  }
  Widget _buildTitle(String title){
    return Text(title,style: TextStyle(color: ThemeColors.textPrimary,fontSize: 28),overflow: TextOverflow.visible,);
  }
  Widget _buildIcon(IconData iconData){
    return Icon(iconData,size: 30,color: ThemeColors.primaryColor,);
  }
  Widget _buildSection(String title){
    return Text(title,style: TextStyle(color: ThemeColors.secondaryColor,fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis,fontSize: 22),);
  }
  Widget _divider(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 0.2,
      color: ThemeColors.dividerColor,
      margin: const EdgeInsets.only(left: 75),
    );
  }

  Widget showTools(){
    ButtonStyle style = ElevatedButton.styleFrom(backgroundColor: ThemeColors.secondaryColor,foregroundColor: ThemeColors.backgroundColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)));
    ButtonStyle _style = ElevatedButton.styleFrom(backgroundColor: ThemeColors.backgroundColor,foregroundColor: ThemeColors.secondaryColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),side: BorderSide(color: ThemeColors.secondaryColor)));
    return Padding(
      padding: const EdgeInsets.only(right: 10,left: 5,top: 10),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              checkLGConnection();
              if(!lgConnected){
                errorTaskButton();
              }else{

                if (_clearingKml) {
                  return;
                }

                setState(() {
                  _clearingKml = true;
                });

                try {
                  await _lgService.clearKml(keepLogos: true);
                } finally {
                  setState(() {
                    _clearingKml = false;
                  });
                }
              }
            },
            style: _style,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buttonText('CLEAR KML'),
                const SizedBox(
                  width: 5,
                ),
                _clearingKml
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 3,color: ThemeColors.secondaryColor),
                )
                    : const Icon(Icons.cleaning_services_rounded)
              ],
            ),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: () async {
              checkLGConnection();
              if(!lgConnected){
                errorTaskButton();
              }else{

                if (_clearingKml) {
                  return;
                }

                setState(() {
                  _clearingKml = true;
                });

                try {
                  await _lgService.clearLogo(3);
                } finally {
                  setState(() {
                    _clearingKml = false;
                  });
                }
              }
            },
            style: _style,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buttonText('CLEAR LOGOS'),
                const SizedBox(
                  width: 5,
                ),
                _clearingKml
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 3,color: ThemeColors.secondaryColor),
                )
                    : const Icon(Icons.cleaning_services_rounded)
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
  Widget buttonText(String text){
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: const TextStyle(
            overflow: TextOverflow.visible,
            fontSize: 18,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  void errorTaskButton(){
    showSnackbar(context, 'Connection failed.');
  }

}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    Key? key,
    this.onCancel,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.buttonText
  }) : super(key: key);

  final String title;
  final String message;
  final Function onConfirm;
  final Function? onCancel;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: ThemeColors.textPrimary),
          ),
        ],
      ),
      backgroundColor: ThemeColors.backgroundColor,
      content: Text(
        message,
        style: TextStyle(color: ThemeColors.textSecondary),
      ),
      actions: [
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: ThemeColors.primaryColor),
          ),
          onPressed: () {
            if (onCancel != null) {
              onCancel!();
            }
          },
        ),
        TextButton(
          child: Text(
            buttonText,
            style: TextStyle(color: ThemeColors.primaryColor),
          ),
          onPressed: () {
            onConfirm();
          },
        ),
      ],
    );
  }
}