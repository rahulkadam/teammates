<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.Map"%>
<%@ page import="java.util.List"%>
<%@ page import="teammates.common.util.Const"%>
<%@ page import="teammates.common.datatransfer.FeedbackParticipantType"%>
<%@ page import="teammates.common.datatransfer.FeedbackResponseAttributes"%>
<%@ page import="teammates.common.datatransfer.FeedbackResponseCommentAttributes"%>
<%@ page import="teammates.common.datatransfer.FeedbackSessionResponseStatus" %>
<%@ page import="teammates.ui.controller.InstructorFeedbackResultsPageData"%>
<%@ page import="teammates.common.datatransfer.FeedbackAbstractQuestionDetails"%>
<%@ page import="teammates.common.datatransfer.FeedbackQuestionAttributes"%>
<%
    InstructorFeedbackResultsPageData data = (InstructorFeedbackResultsPageData) request.getAttribute("data");
    boolean showAll = data.bundle.isComplete;
    boolean shouldCollapsed = data.bundle.responses.size() > 500;
%>
<!DOCTYPE html>
<html>
<head>
    <link rel="shortcut icon" href="/favicon.png">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>TEAMMATES - Feedback Session Results</title>
    <!-- Bootstrap core CSS -->
    <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap theme -->
    <link href="/bootstrap/css/bootstrap-theme.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/stylesheets/teammatesCommon.css" type="text/css" media="screen">
    <script type="text/javascript" src="/js/googleAnalytics.js"></script>
    <script type="text/javascript" src="/js/jquery-minified.js"></script>
    <script type="text/javascript" src="/js/common.js"></script>
    <script type="text/javascript" src="/js/instructor.js"></script>
    <script type="text/javascript" src="/js/instructorFeedbackResults.js"></script>
    <script type="text/javascript" src="/js/additionalQuestionInfo.js"></script>
    <script type="text/javascript" src="/js/instructorFeedbackResultsAjaxByRQG.js"></script>
    <script type="text/javascript" src="/js/instructorFeedbackResultsAjaxResponseRate.js"></script>
    <jsp:include page="../enableJS.jsp"></jsp:include>
    <!-- Bootstrap core JavaScript ================================================== -->
    <script src="/bootstrap/js/bootstrap.min.js"></script>
    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>

<body>
    <jsp:include page="<%=Const.ViewURIs.INSTRUCTOR_HEADER%>" />

    <div id="frameBody">
        <div id="frameBodyWrapper" class="container">
            <div id="topOfPage"></div>
            <div id="headerOperation">
                <h1>Session Results</h1>
            </div>
            <jsp:include page="<%=Const.ViewURIs.INSTRUCTOR_FEEDBACK_RESULTS_TOP%>" />
            <br>

            <% if(!showAll) {
                    int sectionIndex = 0; 
                    for(String section: data.sections){
            %>
                        <div class="panel panel-success">
                                <div class="panel-heading ajax_submit">
                                    <strong><%=section%></strong>
                                    <form style="display:none;" id="seeMore-<%=sectionIndex%>" class="seeMoreForm-<%=sectionIndex%>" action="<%=Const.ActionURIs.INSTRUCTOR_FEEDBACK_RESULTS_AJAX_BY_RQG%>">
                                        <input type="hidden" name="<%=Const.ParamsNames.SECTION_NAME %>" value="<%=section%>">
                                        <input type="hidden" name="<%=Const.ParamsNames.COURSE_ID %>" value="<%=data.bundle.feedbackSession.courseId %>">
                                        <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_SESSION_NAME %>" value="<%=data.bundle.feedbackSession.feedbackSessionName %>">
                                        <input type="hidden" name="<%=Const.ParamsNames.USER_ID%>" value="<%=data.account.googleId %>">
                                        <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_GROUPBYTEAM%>" value="<%=data.groupByTeam%>">
                                    </form>
                                    <div class='display-icon pull-right'>
                                        <span class="glyphicon glyphicon-chevron-down pull-right"></span>
                                    </div>
                                </div>
                                <div class="panel-collapse collapse">
                                <div class="panel-body">
                                </div>
                                </div>
                        </div>
            <%
                    sectionIndex++;
                    }
            %>
                    <div class="panel panel-success">
                            <div class="panel-heading ajax_submit">
                                <strong>None</strong>
                                <form style="display:none;" id="seeMore-<%=sectionIndex%>" class="seeMoreForm-<%=sectionIndex%>" action="<%=Const.ActionURIs.INSTRUCTOR_FEEDBACK_RESULTS_AJAX_BY_RQG%>">
                                    <input type="hidden" name="<%=Const.ParamsNames.SECTION_NAME %>" value="None">
                                    <input type="hidden" name="<%=Const.ParamsNames.COURSE_ID %>" value="<%=data.bundle.feedbackSession.courseId %>">
                                    <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_SESSION_NAME %>" value="<%=data.bundle.feedbackSession.feedbackSessionName %>">
                                    <input type="hidden" name="<%=Const.ParamsNames.USER_ID%>" value="<%=data.account.googleId %>">
                                    <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_GROUPBYTEAM%>" value="<%=data.groupByTeam%>">
                                </form>
                                <div class='display-icon pull-right'>
                                    <span class="glyphicon glyphicon-chevron-down pull-right"></span>
                                </div>
                            </div>
                            <div class="panel-collapse collapse">
                            <div class="panel-body">
                            </div>
                            </div>
                    </div>
            <%
                } else {
            %>

            <%
                boolean groupByTeamEnabled = data.groupByTeam==null ? false : true;
                String currentTeam = null;
                boolean newTeam = false;
                String currentSection = null;
                boolean newSection = false;
                int sectionIndex = 0;
                int teamIndex = 0;
            %>
        <%
            Map<String, Map<FeedbackQuestionAttributes, List<FeedbackResponseAttributes>>> allResponses = data.bundle.getResponsesSortedByRecipientQuestionGiver(groupByTeamEnabled);
            Map<String, Map<FeedbackQuestionAttributes, List<FeedbackResponseAttributes>>> teamResponses = data.bundle.getQuestionResponseMapByRecipientTeam();
            Map<String, FeedbackQuestionAttributes> questions = data.bundle.questions;
            int recipientIndex = 0;
            for (Map.Entry<String, Map<FeedbackQuestionAttributes, List<FeedbackResponseAttributes>>> responsesForRecipient : allResponses.entrySet()) {
                recipientIndex++;
                
                Map<FeedbackQuestionAttributes, List<FeedbackResponseAttributes>> recipientData = responsesForRecipient.getValue();
                Object[] recipientDataArray =  recipientData.keySet().toArray();
                FeedbackResponseAttributes firstResponse = recipientData.get(recipientDataArray[0]).get(0);
                String targetEmail = firstResponse.recipientEmail;

                FeedbackParticipantType firstQuestionRecipientType = questions.get(firstResponse.feedbackQuestionId).recipientType;
                String mailtoStyleAttr = (firstQuestionRecipientType == FeedbackParticipantType.NONE || 
                                firstQuestionRecipientType == FeedbackParticipantType.TEAMS || 
                                targetEmail.contains("@@"))?"style=\"display:none;\"":"";
        %>

        <%
            if(currentTeam != null && !(data.bundle.getTeamNameForEmail(targetEmail)=="" ? currentTeam.equals(data.bundle.getNameForEmail(targetEmail)): currentTeam.equals(data.bundle.getTeamNameForEmail(targetEmail)))) {
                currentTeam = data.bundle.getTeamNameForEmail(targetEmail);
                if(currentTeam.equals("")){
                    currentTeam = data.bundle.getNameForEmail(targetEmail);
                }
                newTeam = true;
        %>
                </div>
                </div>
            </div>
        <%
            }
        %>

        <% 
            if(currentSection != null && !firstResponse.recipientSection.equals(currentSection)){
                currentSection = firstResponse.recipientSection;
                newSection = true;
        %>
                </div>
                </div>
            </div>
        <% 
            }
        %>

        <% if(currentSection == null || newSection == true){
                    currentSection = firstResponse.recipientSection;
                    newSection = false;
                    sectionIndex++;
        %>
                <div class="panel panel-success">
                    <div class="panel-heading">
                        <strong><%=currentSection%></strong>
                        <span class="glyphicon glyphicon-chevron-up pull-right"></span>
                    </div>
                    <div class="panel-collapse collapse in">
                    <div class="panel-body">
                    <a class="btn btn-success btn-xs pull-right" id="collapse-panels-button-section-<%=sectionIndex%>" style="display:block;" data-toggle="tooltip" title='Collapse or expand all <%= groupByTeamEnabled == true ? "team" : "student" %> panels. You can also click on the panel heading to toggle each one individually.'>
                        <%= shouldCollapsed ? "Expand " : "Collapse " %>
                        <%= groupByTeamEnabled == true ? "Teams" : "Students" %>
                    </a>
                    <br>
                    <br>
        <%
            }
        %>

        <%
            if(groupByTeamEnabled == true && (currentTeam==null || newTeam==true)) {
                currentTeam = data.bundle.getTeamNameForEmail(targetEmail);
                if(currentTeam.equals("")){
                    currentTeam = data.bundle.getNameForEmail(targetEmail);
                }
                newTeam = false;
                Map<FeedbackQuestionAttributes, List<FeedbackResponseAttributes>> currentTeamResponses = teamResponses.get(currentTeam);
        %>
                <div class="panel panel-warning">
                    <div class="panel-heading">
                        <strong><%=currentTeam%></strong>
                        <span class="glyphicon glyphicon-chevron-down pull-right"></span>
                    </div>
                    <div class='panel-collapse collapse <%= shouldCollapsed ? "" : "in" %>'>
                    <div class="panel-body background-color-warning">
                        <a class="btn btn-warning btn-xs pull-right" id="collapse-panels-button-team-<%=teamIndex%>" data-toggle="tooltip" title="Collapse or expand all student panels. You can also click on the panel heading to toggle each one individually.">
                            <%= shouldCollapsed ? "Expand " : "Collapse " %> Students
                        </a>
                        <br>
                        <br>
                        <div class="resultStatistics">
                            <%
                                if(currentTeamResponses.size() > 0){
                            %>
                                <h3><%=currentTeam%> Received Responses Statistics </h3>
                                <hr class="margin-top-0">
                                <%
                                    int numStatsShown = 0;
                                    for (Map.Entry<FeedbackQuestionAttributes, List<FeedbackResponseAttributes>> teamResponseEntries : currentTeamResponses.entrySet()) {
                                        FeedbackQuestionAttributes question = questions.get(teamResponseEntries.getKey().getId());
                                        FeedbackAbstractQuestionDetails questionDetails = question.getQuestionDetails();
                                        String statsHtml = questionDetails.getQuestionResultStatisticsHtml(teamResponseEntries.getValue(), question, data.account, data.bundle, "recipient-question-giver");
                                        if(statsHtml != ""){
                                            numStatsShown++;
                                %>
                                            <div class="panel panel-info">
                                                <div class="panel-heading">
                                                    <strong>Question <%=teamResponseEntries.getKey().questionNumber%>: </strong><%=data.bundle.getQuestionText(teamResponseEntries.getKey().getId())%><%
                                                        out.print(questionDetails.getQuestionAdditionalInfoHtml(question.questionNumber, ""));
                                                    %>
                                                </div>
                                                <div class="panel-body padding-0">                
                                                    <div class="resultStatistics">
                                                        <%=statsHtml%>
                                                    </div>
                                                </div>
                                            </div>
                                <%
                                        }
                                    }
                                    if(numStatsShown == 0){
                                %>
                                        <p class="text-color-gray"><i>No statistics available.</i></p>
                            <%
                                    }
                                }
                            %>
                            <%
                                if(currentTeamResponses.size() > 0){
                            %>
                                <h3><%=currentTeam%> Detailed Responses </h3>
                                <hr class="margin-top-0">
                            <%
                                }
                            %>
                        </div>
        <%
            }
        %>


                <div class="panel panel-primary">
                <div class="panel-heading">
                    To: <strong><%=responsesForRecipient.getKey()%></strong>
                        <a class="link-in-dark-bg" href="mailTo:<%= targetEmail%> " <%=mailtoStyleAttr%>>[<%=targetEmail%>]</a>
                    <span class="glyphicon glyphicon-chevron-down pull-right"></span>
                </div>
                <div class='panel-collapse collapse <%= shouldCollapsed ? "" : "in" %>'>
                <div class="panel-body">
                <%
                    int questionIndex = 0;
                    for (Map.Entry<FeedbackQuestionAttributes, List<FeedbackResponseAttributes>> responsesForRecipientForQuestion : responsesForRecipient.getValue().entrySet()) {
                        questionIndex++;
                        FeedbackQuestionAttributes question = responsesForRecipientForQuestion.getKey();
                        FeedbackAbstractQuestionDetails questionDetails = question.getQuestionDetails();
                        List<FeedbackResponseAttributes> responseEntries = responsesForRecipientForQuestion.getValue();
                %>
                        <div class="panel panel-info">
                            <div class="panel-heading">Question <%=question.questionNumber%>: <%
                                    out.print(InstructorFeedbackResultsPageData.sanitizeForHtml(questionDetails.questionText));
                                    out.print(questionDetails.getQuestionAdditionalInfoHtml(question.questionNumber, "recipient-"+recipientIndex+"-question-"+questionIndex));%>
                            </div>
                            <div class="panel-body padding-0">
                                <div class="resultStatistics">
                                    <%=questionDetails.getQuestionResultStatisticsHtml(responseEntries, question, data.account, data.bundle, "recipient-question-giver")%>
                                </div>
                                <table class="table table-striped table-bordered dataTable margin-0">
                                    <thead class="background-color-medium-gray text-color-gray font-weight-normal">
                                        <tr>
                                            <th id="button_sortFromName" onclick="toggleSort(this,1)" style="width: 15%;">
                                                Giver
                                            </th>
                                            <th id="button_sortFromTeam" onclick="toggleSort(this,2)" style="width: 15%;">
                                                Team
                                            </th>
                                            <th id="button_sortFeedback" onclick="toggleSort(this,3)">
                                                Feedback
                                            </th>
                                        </tr>
                                    <thead>
                                    <tbody>
                                        <%
                                            for(FeedbackResponseAttributes responseEntry: responseEntries) {
                                        %>
                                        <tr>
                                        <%
                                            String giverName = data.bundle.getGiverNameForResponse(question, responseEntry);
                                            String giverTeamName = data.bundle.getTeamNameForEmail(responseEntry.giverEmail);
                                        %>
                                            <td class="middlealign"><%=giverName%></td>
                                            <td class="middlealign"><%=giverTeamName%></td>
                                            <td class="multiline"><%=responseEntry.getResponseDetails().getAnswerHtml(questionDetails)%></td>
                                        </tr>        
                                        <%
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                <%
                    }
                %>
                </div>
                </div>
            </div>
        <%
            }
        %>

        <%
            //close the last team panel.
            if(groupByTeamEnabled==true) {
        %>
                    </div>
                    </div>
                </div>
        <%
            }
        %>

                </div>
                </div>
            </div>

        <%
            }
        %>

        <% if(data.selectedSection.equals("All") && data.bundle.responses.size() > 0){ %>
            <div class="panel panel-warning">
                <div class="panel-heading<%= showAll ? "" : " ajax_response_rate_submit"%>">
                    <form style="display:none;" id="responseRate" class="responseRateForm" action="<%=Const.ActionURIs.INSTRUCTOR_FEEDBACK_RESULTS_AJAX_RESPONSE_RATE%>">
                        <input type="hidden" name="<%=Const.ParamsNames.COURSE_ID %>" value="<%=data.bundle.feedbackSession.courseId %>">
                        <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_SESSION_NAME %>" value="<%=data.bundle.feedbackSession.feedbackSessionName %>">
                        <input type="hidden" name="<%=Const.ParamsNames.USER_ID%>" value="<%=data.account.googleId %>">
                    </form>
                    <div class='display-icon pull-right'>
                    <span class="glyphicon <%= showAll ? "glyphicon-chevron-up" : "glyphicon-chevron-down" %> pull-right"></span>
                    </div>
                    Participants who have not responded to any question</div>
                <div class="panel-collapse collapse <%= showAll ? "in" : "" %>">
            <% if(showAll) {
                // Only output the list of students who haven't responded when there are responses.
                FeedbackSessionResponseStatus responseStatus = data.bundle.responseStatus;
                if (data.selectedSection.equals("All") && !responseStatus.noResponse.isEmpty()) {
            %>          
                    <div class="panel-body padding-0">
                        <table class="table table-striped table-bordered margin-0">
                            <tbody>
                            <%  
                                List<String> students = responseStatus.getStudentsWhoDidNotRespondToAnyQuestion();
                                for (String studentName : students) {
                            %>
                                    <tr>
                                        <td><%=studentName%></td>
                                    </tr>
                            <%
                                }
                            %>
                            </tbody>
                        </table>
                    </div>
            <%
                    } else {
            %>
                    <div class="panel-body">
                        All students have responsed to some questions in this session.
                    </div>
            <%
                    }
                } 
            %>
                </div>
                </div>
            <% } %>
        </div>
    </div>

    <jsp:include page="<%=Const.ViewURIs.FOOTER%>" />
</body>
</html>