
class CourseLecturePost extends StatefulWidget {
  final int courseNumber;
  CourseLecturePost({
    Key key,
    this.courseNumber,
  }) : super(key: key);
  final String routeName = 'course_lecture_post';
  @override
  _CourseLecturePostState createState() => _CourseLecturePostState();
}

class _CourseLecturePostState extends State<CourseLecturePost> {
  final _scafolkey = GlobalKey<ScaffoldState>();

@override
  void initState() {
    getCoursePost(widget.courseNumber);
    scrollindecator();
    super.initState();
  }

  ScrollController _scrollController = new ScrollController();

  void scrollindecator() {
    _scrollController.addListener(
      () {
        if (_scrollController.offset >=
                _scrollController.position.maxScrollExtent &&
            !_scrollController.position.outOfRange) {
          getCoursePost(widget.courseNumber);
        }
      },
    );
  }

  getCoursePost(courseId) {
    Provider.of<PostProvider>(context, listen: false).getCoursePost(courseId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return null;
      },
      child: Scaffold(
        key: _scafolkey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
            },
          ),
          title: Text("removed title"),
          ),
          centerTitle: true,
          toolbarHeight: 50.0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
          },
          // backgroundColor: Colors.purple,
          child: Icon(Icons.add),
        ),
        body: Consumer<PostProvider>(builder:
            (BuildContext context, PostProvider postProvider, Widget child) {
          return ListView.separated(
            controller: _scrollController,
            separatorBuilder: (context, index) =>
                divider(height: 6, thickness: 1, indent: 80),
            itemCount: postProvider.postModel.length,
            itemBuilder: (BuildContext context, int index) {
              if (index + 1 == postProvider.postModel.length &&
                  postProvider.finish != null) {
                return Center(
                    child: CircularProgressIndicator(
                ));
              } else {
                return textPost(
                    context,
                    widget.courseNumber,
                    _scafolkey);
              }
            },
          );
        }),
      ),
    );
  }
}


class PostProvider extends BaseProvider {
  PostService _postService = PostService();

  List<PostModel> _postModel = [];
  List<PostModel> get postModel => _postModel;

//this is for pagination
  String nextPageNumber = 'first';
  String finish = 'empty';

  Future<void> getCoursePost(int courseId) async {
    if (finish != null) {
      var response;
      //or send {"page": 1} it is up to you just think!! how to emplement
      if (nextPageNumber == 'first') {
        response = await _postService.getcoursepost(courseId, null);
      } else {
        response = await _postService
            .getcoursepost(courseId, {"page": nextPageNumber});
      }
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        finish = body['next_page_url'];
        if (body['next_page_url'] != null) {
          //up to you how do you want!! there are many easy way
          nextPageNumber = Regex.getUrlParameterNumber(body['next_page_url']);
        }
        var data = body['data'];
        data.forEach((course) {
          _postModel.add(PostModel.fromJson(course));
        });
      }
      notifyListeners();
    } else {
      nextPageNumber = 'first';
    }
  }
}

class Regex {
  static getUrlParameterNumber(String url) {
    int length = url.length;
    String number = '';
    for (var i = 0; i < length; i++) {
      if (url[i] + url[i + 1] + url[i + 2] + url[i + 3] == 'page') {
        number = url.substring(i + 5, length);
        break;
      }
    }
    return number;
  }
}

