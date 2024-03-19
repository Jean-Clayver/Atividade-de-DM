import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp()); /*MyApp executa a classe abaixo, nomeando o app e
                  e tema visual e o widget "inicial", ou seja, o ponto de partida do app*/
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); //Servem como base para a criação de apps do Flutter

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 33, 59, 255)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random(); 
  /*Define o estado do app e os dados necessários para o app funcionar.
  A classe "state" estende o ChangeNotifier, 
  o que significa que ela pode emitir notificações sobre suas próprias mudanças. */
  void getNext(){
    current = WordPair.random();
    notifyListeners(); /*Envia uma notificação a 
    qualquer elemento que esteja observando MyAppState*/
  }
  var favorites = <WordPair>[];
  //São armazenadas em uma lista vazia pares de palavras que você curtiu em uma propriedade
  //chamada "favorites"

  void toggleFavorite(){
    if(favorites.contains(current)){
      favorites.remove(current);
    } else{
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  //dessa forma estende-se o State e pode mudar seus próprios valores
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                /**Garante que os filhos não sejam ocultos por um entalhe de hardware
                 * ou uma barra de status.
                */
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  /*(false)Ao mudar para true, isso permite mostrar os rótulos ao lado dos ícones. */
                  destinations: [
                    /**O NavegationRail ocupa apenas os espaços necessários*/
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  //É respectivo ao indice de destino
                  onDestinationSelected: (value)
                  /**A coluna de navegação também define 
                   * o que acontece quando o usuário seleciona um dos destinos  */ 
                   {
                    setState((){
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                //usa-se quando precisa ocupar o máximo possível do espaço restante
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ), 
            ],
          ),
        );
      }
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      // permite mudar muito mais o estilo do texto do que apenas a cor.
      color: theme.colorScheme.onPrimary,
    );
    // o código solicita o tema atual do app com Theme.of(context).

    return Card(
      //Isso encapsula o widget Padding e, portanto, também o Text ideia aleatória, com um widget Card.
      color: theme.colorScheme.primary,
      /*define a cor do card para ser a mesma da propriedade colorScheme do tema.
      ao mudar de cor acontece uma animação, chamada "Animação implícita" 
      O esquema de cores é muito variado, e primary é a cor de mais destaque do app*/
      
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase, 
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
          ),
      ),
    );
  }
}
class FavoritesPage extends StatelessWidget {
  //Detecta o estado atual do app
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      /**Se a lista de favoritos estiver vazia, a mensagem centralizada: No favorites yet
       * Caso contrário, aparecerá uma lista rolável e a quantidade de favoritos
       */
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      //É uma Column rolável
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            //tem propriedades como title(texto), leading(ícones ou avatares) 
            //e onTap(interações)
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}
