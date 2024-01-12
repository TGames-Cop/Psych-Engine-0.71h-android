package options;

class PluginSubState extends BaseOptionsMenu
{
    public function new()
        {
            if (ClientPrefs.data.language == 'Inglish') {
            title = 'Plugins Settings';
            rpcTitle = 'Plugins Settings Menu';

            MusicBeatState.updatestate("PluginsMenu");

            var option:Option = new Option("Color Plus",
            "A color effect that increases its intensity and saturation automatically\nYour Device is Not Compatible with Plugins!",
            "colorplus",
            "bool");
            option.onChange = save;
            addOption(option);

            var option:Option = new Option("More Debug",
            "Increase the information in the titles in the corner for more information\nYour Device is Not Compatible with Plugins!",
            "moredebug",
            "bool");
            option.onChange = save;
            addOption(option);

            var option:Option = new Option("Setings Max",
            "Increase priorities with your Preferences\nYour Device is Not Compatible with Plugins!",
            "settingsmax",
            "bool");
            option.onChange = save;
            addOption(option);
            }


////////////////////////////////////////////////////////////////////////////////////////////////////////////


            if (ClientPrefs.data.language == 'Spanish') {
                title = 'Ajustes de Plugins';
                rpcTitle = 'Menu de Ajustes de Plugins';
    
                MusicBeatState.updatestate("PluginsMenu");
    
                var option:Option = new Option("Color más",
                "Un efecto de color que aumenta su intensidad y saturación automáticamente\n!Tu Dispositivo no es Compatible con Plugins!",
                "colorplus",
                "bool");
                option.onChange = save;
                addOption(option);
    
                var option:Option = new Option("Más depuración",
                "Aumenta la información en los títulos en la esquina para más información.\n!Tu Dispositivo no es Compatible con Plugins!",
                "moredebug",
                "bool");
                option.onChange = save;
                addOption(option);
    
                var option:Option = new Option("Configuración máx.",
                "Aumenta las prioridades con tus Preferencias\n!Tu Dispositivo no es Compatible con Plugins!",
                "settingsmax",
                "bool");
                option.onChange = save;
                addOption(option);
            }


///////////////////////////////////////////////////////////////////////////////////////////////////////


            if (ClientPrefs.data.language == 'Portuguese') {
                title = 'Configurações de plug-in';
                rpcTitle = 'Menu de configurações do plug-in';
    
                MusicBeatState.updatestate("PluginsMenu");
    
                var option:Option = new Option("Cor Mais",
                "Um efeito de cor que aumenta automaticamente sua intensidade e saturação\nSeu dispositivo não é compatível com plug-ins!",
                "colorplus",
                "bool");
                option.onChange = save;
                addOption(option);
    
                var option:Option = new Option("Mais depuração",
                "Aumente as informações nos títulos no canto para mais informações.\nSeu dispositivo não é compatível com plug-ins!",
                "moredebug",
                "bool");
                option.onChange = save;
                addOption(option);
    
                var option:Option = new Option("Configuração máxima",
                "Aumente as prioridades com suas preferências\nSeu dispositivo não é compatível com plug-ins!",
                "settingsmax",
                "bool");
                option.onChange = save;
                addOption(option);
            }

            super();
        }

        public function save() {
            ClientPrefs.saveSettings();
            ClientPrefs.loadPrefs();
        }
}