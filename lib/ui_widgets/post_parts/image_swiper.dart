import 'package:flutter/material.dart';

class ImageSwiper extends StatefulWidget {
  final List<dynamic> imageUrls; // 表示する画像のURLリスト

  const ImageSwiper({super.key, required this.imageUrls});

  @override
  _ImageSwiperState createState() => _ImageSwiperState();
}

class _ImageSwiperState extends State<ImageSwiper> {
  int _currentIndex = 0; // 現在表示している画像のインデックス

  final PageController _pageController = PageController();

  void _previousImage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeIn,
    );
  }

  void _nextImage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index) {
            return Image.network(widget.imageUrls[index], fit: BoxFit.cover);
          },
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child:Visibility(
            visible: widget.imageUrls.length > 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: _currentIndex > 0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: _previousImage,
                      ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.imageUrls.length,
                            (index) => Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == index
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _currentIndex < widget.imageUrls.length - 1,
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: _nextImage,
                    ),
                  )
                ],
              ),
          ),

        ),
      ],
    );
  }
}