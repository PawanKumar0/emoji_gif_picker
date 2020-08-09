import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker/page_indicator.dart';
import 'package:flutter/material.dart';
import 'package:giphy_client/giphy_client.dart';
import 'emoji_picker.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class TextComposer extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String) onSend;
  final void Function(String) onSelectGif;
  final Future<GiphyCollection> Function({bool reload}) getGifData;
  final Function mediaPicker;

  ///default rows = 6
  final int rows;

  ///default columns = 9
  final int columns;

  final Color color;

  final String hintText;

  const TextComposer({
    Key key,
    this.controller,
    this.onSend,
    this.rows: 6,
    this.columns: 9,
    this.color,
    this.mediaPicker,
    this.hintText,
    this.onSelectGif,
    this.getGifData,
  }) : super(key: key);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  TextEditingController _controller;

  bool showEmoji = false;

  int _cursorPosition = -1;

  FocusNode _nodeText = FocusNode();

  double _index;

  PageController _pageController;

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  final client = new GiphyClient(apiKey: 'bJx9xBfgsln73Susl7ozNOJlj370WrFz');
  GiphyCollection collection;

  bool keyboardVisible = false;

  @override
  initState() {
    super.initState();
    _nodeText = FocusNode();
    _pageController = new PageController();

    _index = 0;
    _controller = widget.controller ?? TextEditingController();

    _nodeText.addListener(() {
      if (_nodeText.hasFocus) {
        if (mounted && showEmoji)
          setState(() {
            showEmoji = false;
          });
        if (_controller.selection.baseOffset < 0) {
          _controller.selection = TextSelection.fromPosition(TextPosition(offset: _cursorPosition));
        }
      }
    });

    _controller.addListener(() {
      if (_controller.selection.baseOffset >= 0) {
        _cursorPosition = _controller.selection.baseOffset;
      }
    });

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        if (showEmoji) {
          setState(() {
            keyboardVisible = visible;
          });
        } else {
          keyboardVisible = visible;
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<GiphyCollection> _getGifData({bool reload: false}) async {
    if (reload || collection == null)
      collection = await (widget.getGifData(reload: false) ?? client.trending(offset: 1, limit: 1000, rating: GiphyRating.pg));

    return collection;
  }

  @override
  dispose() {
    _nodeText?.dispose();
    if (widget.controller != null) _controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildTextComposer(),
          Visibility(
              visible: showEmoji && !keyboardVisible,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: (MediaQuery.of(context).size.width / widget.columns) * widget.rows + 60,
                    child: PageView.builder(
                      controller: _pageController,
                      itemBuilder: (_, page) {
                        switch (page) {
                          case 0:
                            return EmojiPicker(
                              rows: widget.rows,
                              columns: widget.columns,
                              // recommendKeywords: ["racing", "horse"],
                              numRecommended: 10,
                              onEmojiSelected: (emoji, category) {
                                _controller.text = _controller.text.substring(0, _cursorPosition) +
                                    emoji.emoji +
                                    _controller.text.substring(_cursorPosition);

                                _cursorPosition += emoji.emoji.length;
                                _controller.selection = TextSelection.fromPosition(TextPosition(offset: _cursorPosition));
                              },
                            );

                          case 1:
                            return FutureBuilder<GiphyCollection>(
                                future: _getGifData(),
                                builder: (context, snapshot) {
                                  if (snapshot?.data == null || snapshot.connectionState != ConnectionState.done)
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  final _gifs = snapshot.data;

                                  return GridView.count(
                                    crossAxisCount: 2,
                                    primary: false,
                                    children: _gifs.data
                                        .where((gif) => gif?.images?.fixedHeightDownsampled?.url != null)
                                        .map((gif) => GestureDetector(
                                              onTap: () {
                                                widget.onSelectGif(gif.images.fixedHeightDownsampled.url);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: CachedNetworkImage(
                                                  height: 200,
                                                  fit: BoxFit.cover,
                                                  imageUrl: gif.images.fixedHeightDownsampled.url,
                                                  httpHeaders: {'accept': 'image/*'},
                                                  errorWidget: (_, __, ___) => Text(gif.images.previewGif.url ?? __),
                                                  placeholder: (_, __) => Center(
                                                    child: CircularProgressIndicator(),
                                                  ),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  );
                                });
                          // case 2:
                          //   return Text('Pick a voice..');
                          default:
                            return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  PageIndicator(
                    controller: _pageController,
                    itemCount: 2,
                    color: widget.color,
                    onPageSelected: (int page) {
                      _pageController.animateToPage(
                        page,
                        duration: _kDuration,
                        curve: _kCurve,
                      );
                    },
                  ),
                  // SizedBox(
                  //   height: 8,
                  // )
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return new Container(
        padding: const EdgeInsets.all(4.0),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: new BoxDecoration(color: Colors.blueGrey[50], borderRadius: const BorderRadius.all(const Radius.circular(24.0))),
        constraints: BoxConstraints(maxHeight: 104.0),
        child: new Row(children: <Widget>[
          IconButton(
              icon: showEmoji ? Icon(Icons.keyboard_hide) : Icon(Icons.insert_emoticon),
              splashColor: Colors.transparent,
              // focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () {
                // _nodeText.unfocus();

                setState(() {
                  showEmoji = !showEmoji;
                });

                if (!showEmoji) {
                  _nodeText.requestFocus();
                }
              }),
          new Flexible(
            child: new TextField(
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _controller,
              readOnly: showEmoji,
              showCursor: true,
              // onChanged: _parseContent,
              focusNode: _nodeText,
              decoration: new InputDecoration.collapsed(
                hintText: widget.hintText ?? "Send a message",
              ),
            ),
          ),
          new Container(
            child: new IconButton(icon: new Icon(Icons.photo_camera), onPressed: widget.mediaPicker),
          ),
          new Container(
            //margin: new EdgeInsets.symmetric(horizontal: 2.0),
            child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () {
                  if (widget.onSend != null) widget.onSend(_controller.text);
                  setState(() {
                    // _text.add(_controller.text);
                    _controller.text = "";
                  });
                }),
          ),
        ]));
  }
}
