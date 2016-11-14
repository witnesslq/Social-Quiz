<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<html>
<head>
<title>Quiz</title>
<!--jQuery-->
<script src="http://code.jquery.com/jquery-latest.js"></script>
<!--bootstrap-->
<link rel="stylesheet" href="http://cdn.bootcss.com/bootstrap/3.3.4/css/bootstrap.min.css">
<script src="http://cdn.bootcss.com/jquery/1.11.2/jquery.min.js"></script>
<script src="http://cdn.bootcss.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
<link href="css/navbar.css" rel="stylesheet" type="text/css" />

<%-- java prepare data --%>
<%@ page language="java" import="com.db.Dao, com.model.*, java.util.*, javafx.util.Pair" pageEncoding="UTF-8"%>
<%
	//PREPARE DATA FOR THE PAGE
	//connect to database
	Dao dao = new Dao();
	//get current viewer's information
	User user = (User)session.getAttribute("user");
	//get quiz
	Quiz quiz;
	if (request.getParameter("id")!=null){
		quiz = dao.getQuiz(Integer.parseInt(request.getParameter("id")));
	} else {
		quiz = dao.getQuiz((Integer)session.getAttribute("quizId"));
	}
	//get quiz's creator's information
	User owner = dao.getUser(quiz.getOwnerID());
	//get quiz's questions
	Vector<Question> questions = new Vector<Question>();
	for (int i : quiz.getQuestions()) {
		questions.add(dao.getQuestion(i));
	}
%>

<!-- javascript generate the web page -->
<script type="text/javascript">
	$(document).ready(function(){		
		$('#quizId').val('<%=quiz.getId()%>');
		$('#title').text('<%=quiz.getTitle()%>');
		$('#owner').text('<%=owner.getNickName()%>');
		$('#type').text('<%=quiz.getType()%>');
		$('#description').text('<%=quiz.getDescription()%>');
	<%! int no = 1;%>
	<%-- Vector<String> options = new Vector<String>();--%>
	<% 	for (int i=0; i<questions.size(); ++i) {
			Question ques = questions.elementAt(i);
			switch (ques.getType()) {
			//Short Answer
			case 'S':%>
			$('#quiz').append(
		'<div class="question question-SA">\
			<div class="question-basis">\
				<span class="no"></span><span>.</span>\
				<span class="user-score"></span>\
				<span class="content"></span>\
				<span class="tag"></span>\
			</div>\
			<div class="question-answer">\
				<div class="not-done">\
					<input type="text" class="answer form-control"/>\
				</div>\
				<div class="input-group done">\
					<input type="text" class="answer-user form-control" readonly="readonly"/>\
					<span class="input-group-addon user-star"></span>\
				</div>\
				<div class="input-group owner">\
					<input type="text" class="answer-correct form-control" readonly="readonly">\
					<span class="input-group-addon star"></span>\
				</div>\
				<input type="text" class="score" style="display:none">\
			</div>\
		</div>');
			<%
			String[] SA_splits = ques.getAnswer().split("\\^",-1);
			String SA_answer = SA_splits[0];
			int SA_score = Integer.parseInt(SA_splits[1]);
			%>
			$('.answer-correct:last').val('<%=SA_answer%>');
			$('.score:last').val('<%=SA_score%>');
			$('.question:last').addClass('panel panel-success');
			$('.tag:last').addClass('label label-success').css('margin-left','3%');
			<%for (int j=1; j<=SA_score; ++j){%>
				$('.star:last').append('<span class="glyphicon glyphicon-star"></span>');
			<%}
			break;
			//Multiple Choices
			case 'M':
			Vector<String> contents = ques.getMC().getKey();
			Vector<Integer> scores = ques.getMC().getValue();
			%>
			$('#quiz').append(
		'<div class="question question-MC">\
			<div class="question-basis">\
				<span class="no"></span><span>.</span>\
				<span class="user-score"></span>\
				<span class="content"></span>\
				<span class="tag"></span>\
			</div>\
			<div class="question-answer"></div>\
		</div>');
			<%//add options
			int mark = 65;
			for (int j=0; j<contents.size(); ++j){%>
				$('.question-answer:last').append(
				'<div class="input-group">\
					<span class="input-group-addon mark"></span>\
					<span class="option-content form-control"></span>\
					<span class="input-group-addon not-done">\
						<input type="radio" name="options">\
						<input class="score" type="text" style="display:none" >\
					</span>\
					<span class="input-group-addon done star"></span>\
					<span class="input-group-addon owner star"></span>\
				</div>');
				$('.mark:last').text('<%=(char)mark++%>');
				$('.option-content:last').text('<%=contents.elementAt(j)%>');
				$('.question:last .score').val('<%=scores.elementAt(j)%>');
				<%for (int k=1; k<=scores.elementAt(j);++k){%>
					$('.star:last').append('<span class="glyphicon glyphicon-star"></span>');
				<%}%>
			<%}%>
			$('.question:last').addClass('panel panel-info');
			$('.tag:last').addClass('label label-success');
			<%
				break;
			default:
			//True or False%>
			$('#quiz').append(
		'<div class="question question-TF">\
			<div class="question-basis">\
				<span class="no"></span><span>.</span>\
				<span class="user-score"></span>\
				<span class="content"></span>\
				<span class="tag"></span>\
				<span class="not-done">\
					<input type="checkbox" style="float:right">\
					<input type="text" class="answer" value="F" style="display:none">\
				</span>\
				<span class="done">\
					<input type="checkbox" class="answer-user" disabled="disabled" >\
					<span class="star-user" style="float:right"></span>\
				</span>\
				<span class="owner">\
					<input type="text" class="answer-correct" style="display:none">\
					<input type="checkbox" disabled="disabled">\
					<span class="star" style="float:right"></span>\
				</span>\
				<input type="text" class="score" style="display:none">\
			</div>\
		</div>');
			<%String[] TFSplits = ques.getAnswer().split("\\^",-1);
			String TF_answer = TFSplits[0];
			int TF_score = Integer.parseInt(TFSplits[1]);%>
			$('.answer-correct:last').val('<%=TF_answer%>');
			$('.score:last').val('<%=TF_score%>');
			$('.question:last').addClass('panel panel-warning');
			$('.tag:last').addClass('label label-warning');
			<%if(TF_answer.equals("T")){%>
				$('.answer-correct:last').next().attr('checked','checked');
			<%}
			for (int j=1; j<=TF_score; ++j) {%>
				$('.star:last').append('<span class="glyphicon glyphicon-star"></span>');
			<%}
			}%>
			$('.no:last').append('<%=no%>');
			$('.content:last').append('<%=ques.getContent()%>');
			$('.tag:last').append('<%=ques.getTag()%>');
			<%no++;
		}%>
		$('.question-basis').addClass('panel-heading');
		$('.question-answer').addClass('panel-body');
		$('.content,.no').addClass('panel-title');
		$('.tag').css('margin-left','3%');
		$('[type="checkbox"]').change(function(){setSelVal(this);});
		<%no=1;
		if (user.getId() == owner.getId()) {//creator' perspective %>
			$('.done,.not-done').css('display','none');
			$('#basis').append('<a style="margin-bottom:3%;margin-top:3%;" class="btn-primary form-control" href="rank?id='+ '<%=quiz.getId()%>' +'">查看排行榜</a>');
			$('#quizID').val('<%=quiz.getId()%>');
		<%} else if (user.getQuizDone().indexOf(quiz.getId())==-1) {//quiz doer's perspective %>
			$('.owner,.done').css('display','none');
			$('#quiz').append('<input style="margin-bottom:3%" type="submit" style="margin:3%" class="form-control btn-success" value="Submit">');
		<%} else {//quiz doner's perspective %>
			$('#basis').append('<a style="margin-bottom:3%;margin-top:3%" class="btn-danger form-control" href="rank?id='+ '<%=quiz.getId()%>' +'">查看排行榜</a>');
			$('#quizID').val('<%=quiz.getId()%>');
			$('.owner,.not-done').css('display','none');
		<% 	
			Vector<Pair<String, Integer>> rec = quiz.getRecord(user.getId()); 
			int finalScore = 0;
			for (int k=0; k<rec.size(); ++k) {
				finalScore += rec.elementAt(k).getValue();
			} %>
			$('#quiz').prepend('<h3>Your final score is <span class="score-final">' + '<%=finalScore%>' + '</span></h3>');
		<%	String answer_user;
			int score_user;
			for (int count = 0; count<rec.size(); ++count) {%>
				var q = $('.question:eq(' + '<%=count%>' + ')');
				<%
				answer_user = rec.elementAt(count).getKey();
				score_user = rec.elementAt(count).getValue();
				%>
				q.find('.user-score').text('+'+'<%=score_user%>');
				if (q.is('.question-SA')) {
					$(this).find('.answer-user').val('<%=answer_user%>');
					<%if (score_user==0) {%>
						$(this).find('.done').removeClass('input-group');
						$(this).find('.user-star').remove();
					<%} else {
						for (int j=0; j<score_user; ++j) {%>
							$(this).find('.user-star').append('<span class="glyphicon glyphicon-star"></span>');
					<%}
					} %>
				} else if (q.is('.question-MC')) {
					$(this).find('.mark').each(function(){
						if ($(this).is('.mark:contains("' + '<%=answer_user%>' + '")')){
							<%for (int j=0; j<score_user; ++j) {%>
							$(this).next().next().next()
									.append('<span class="glyphicon glyphicon-star"></span>');
							<%}%>
						} else {
							$(this).next().next().next().remove();
						}
					});
				} else {
					<%if(answer_user.equals("T")){%>
					$(this).find('.answer-user').attr('checked', 'checked');
					<%}
					if (score_user==0){%>
						$(this).find('.star-user').remove();
					<%} else
						for (int j=1; j<=score_user; ++j) {%>
							$(this).find('.star-user').append('<span class="glyphicon glyphicon-star"></span>');
						<%}%>
				}
			<%}
		}%>
		$('.score-final').css('color','red').css('font-size','larger')
		$('.user-score').addClass('panel-title').css('color','red');
		$('.glyphicon-star').css('color','orange');
		$('nav').load('HTML/nav.html');

	});

	function setSelVal(thisSel) {
		if ($(thisSel).is(':checked')) {
			$(thisSel).next().val('T');
		} else {
			$(thisSel).next().val('F');
		}
	}
	
	function calculate() {
		if (confirm('Are you sure to submit?')==false) {
			return false;
		}
		var rec = "";
		var total = 0;
		$('.question').each(function(){
			rec += '$';
			if ($(this).is('.question-SA') || $(this).is('.question-TF')) {
				if ($(this).is('.question-SA')) {
					rec += 'S';
				} else {
					rec += 'T';
				}
				var answer = $(this).find('.answer').val();
				var correctAnswer = $(this).find('.answer-correct').val();
				var score = $(this).find('.score').val();
				rec += '~' + answer;
				if (answer == correctAnswer) {
					rec += '~' + score;
					total += Number(score);
				} else {
					rec += '~0';
				}
			} else {
				rec += 'M';
				var found = false;
				$(this).find('[type="radio"]').each(function(){
					if ($(this).is(':checked')) {
						found = true;
						rec += '~' + $(this).parent().prev().prev().text();
						var score = $(this).next().val();
						rec += '~' + score;
						total += Number(score);
					}
				});
				if (found==false){
					rec += '~~0';
				}
			}
		});
		$('#record').val(rec + '|' + total + '|' + '<%=user.getId()%>');
		$('#quizId').val('<%=quiz.getId()%>');
		return true;
	}
</script>

</head>
<body>
	<nav class="navbar navbar-default" role="navigation"></nav>

	<div class="container">
		<div class="row">
			<div class="col-md-8 col-md-offset-2 col-xs-10 col-xs-offset-1">
				<div id="basis" class="page-header">
					<h1 id="title"></h1>
					<h3 id="owner" style="color: blue; text-align: right"></h3>
					<span id="type" class="label label-info" style="font-size: 15px"></span> 
					<span id="description" style="color:gray; font-size: 20px"></span>
				</div>
				<form id="quiz" onsubmit="return calculate();" action="doQuiz" method="post">
					<div style="display:none">
						<input type="text" name="record" id="record">
						<input type="text" name="quizId" id="quizId">
					</div>
				</form>
			</div>
		</div>
	</div>

</body>
</html>