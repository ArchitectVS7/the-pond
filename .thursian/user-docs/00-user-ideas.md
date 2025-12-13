OK, this is a lot. And I don’t know how some of it can be done, but I do think I have an orchestration solution.

Earlier you and I talked about the feasibility of NHN and Claude code, and I think we landed on that wasn’t really feasible. However, I saw a YouTuber talk about how he used SSH to connect N8N to Claude code, and if that is true, then N8N becomes a much more rigid orchestra and can get me much more deliberate tool calling. My problem with running complex workflows inside of Claude code is when Claude decides not to follow instructions. For example, if the orchestrate decides to do the task instead of passing it to a sub agent, then the orchestrate runs out of context and tokens. Or sometimes the orchestrate or the sub agent, decides not to follow instructions and the code drift. In a surprising number of instances, a sub agent will claim that they have written a specification, and there is no markdown file, or they have written code, and there is no code, because they were in a simulated environment. People have done various things with making more and more complicated skills and agents and/commands to try and enforce the tool calls. Ultimately, I do think a more rigid orchestra is in order, and as you will see, I do have a workflow with a number of steps. I don’t think this is particularly advanced, I just think it’s too advanced for a one shot prompt, definitely needs an orchestrate. What I am trying to do is go from an initial idea all the way to finish product. But rather than a cheap one shot prompt, I want to back that up with real market research, as well as creating user personas that might inject some personality and creativity into the process. 
 


This is my idea for a complete plan from ideation all the way through finish product. I am trying to think of this in terms of how a product would be developed by human teams that take into account player wants and needs, market research, and generally accepted domain expertise, while looking for a room for creativity. The Genesis comes in two forms: 

1A: an initial idea is input from the user. This is the idea for an application, a game, and while this current workflow is going to be based on coding, we could use a very similar workflow for document creation, such as writing a book or creating a business plan. Those we will stub as out of scope for now, but save for future discussion.

1B: the second way this workflow starts is a resurrection loop. The way the resurrection loop starts is I go to a repository for a stalled project. We look for any existing PRD or other design documentation if it exists, we look at the code as it exists. We tried to infer the original mission and vision as best we can.

Both use cases then start the below workflow that expands the idea, brings in additional opinions, and lands on a finished product.

2 - auto ideation
In this step, I envision two friends conversing back-and-forth. One of them takes on the role of me who gave the initial idea, or the stalled repository. This persona is a dreamer, always living in the “what if”. The other persona is a doer, always living in the “let’s build it”. They automatically converse back-and-forth until an executive vision for the project is made. 

OUTPUT: Vision statement of 1-3 pages, something that really excites the Dreamer and really seems doable. The Doer reaches an “ah-ha” moment and says “let me call a group of friends”

3 - auto focus group
at this point, Dreamer calls up his buddies in the relevant domain (gaming, productivity, automation, etc) We will spawn five end user personas across a few demographics applicable to the coding idea, for example if gaming might pick a board gamer, card gamer, mobile, pc, and at least one game designer. The Doer acts as a facilitator. We do five focus group rounds, where the facilitator asks context-relevant questions, and everyone shines in. Round 1: discussion of the game idea
Round 2-5: context aware follow ups
2: expanding wider
3: diving deeper
4: pain points 
5: final thoughts 
A note for this and all focus group sessions, we alsowant to do actual web based research in parallel. For example, when looking for user feedback, we want to look at actual game reviews, user scores, subreddit posts, and the demographics associated. If we can align actual research with our user personas, we can make our simulated focus group actually useful. Same will go with engineering reviews below.

4 - Doer next brings this idea to his engineering friends. This is an initial design round table. One or more domain experts )such as a game designer), business manager, marketing analyst, etc for another five person round table, and they create a PRD. Conduct actual web research into what is available and what are gaps for this idea or product. Beware of saturation, focus on gaps, leverage existing code libraries that may exist for major functions.

The prd will be as industry standard, describing the WHAT of the product, not yet the HOW. Follow the round table format

5 - Engineering Manager checks in with focus group and Dreamer
Doer introduces Dreamer to the Engineering Manager and the focus group. They each talk about what excites them about them the idea. Engineering manager presents the PRD section by section. Everybody has a chance to chime in. Does it need dreamers initial vision? Does it mean the focus group’s excitement, satisfy the pain points? Each section of the PRD gets five rounds of review:

1: initial reactions 
2: anything missing you thought would be here
3: anything here you would like to see changed 
4: of the group’s total feedback of all issues, which ones would you say are most critical?
5: of the groups, total feedback of all issues, which ones would you say are nice to have?


6 - engineering review 
Engineering Manager brings back  the second focus group output. Not every single discussion point is taken for action. At this point, they are focused on build, MVP, alpha testing, beta testing. Some features the users ask for might be nice to have, might be out of scope, might be critical. A PRD revision is put together.

7 - architecture planning 
Spawning as many number of steps as as needed, create architecture documents. Depending on target audience, platform, deployment, layout, the structure, modules, communication, authentication, all the technical details.

8 - scheduling 
invoking a project manager persona, layout epics and story bullet points. Stories should just be feature slugs for future expansion and not verbose. Established a traceability matrix. Every FS and NFS has traceability to the PRD. There are priorities and milestones and assets required. The project manager knows when we need an expert in python or C# or SQL.

9 - iterate a number of planning stages to take all of those stories and flesh out into detailed plans with blockers, dependencies, responsibilities, still forth. The plan should be enough to highlight any issues beforehand, but also be able bulletproof recipe to follow.

10 - approval for build 
Every person of engineering board reviews every document for consistency. Iterate only a max of 3 times. If cannot attain 95% approval stop

11 - build prototype 
Absolute minimum buildable part is designed and tested. Every step has a second check and a test. When we get to the build step, the system automatically “plays the game“ or “uses the application”. Perhaps in a browser, such as playwright or puppeteer. Screenshots are saved to the hard drive.

12 alpha test 
Take all test reports and screenshots from the self run tests of the application back to the focus group plus Dreamer and Doer plus the engineering focus group. This is the “closed alpha group”. Re-perform the user testing if necessary, this is where I really think the system can start to shine. I want to simulate a full-blown closed alpha test where every button is clicked, text is entered into text boxes, responses are reviewed, screenshots are taken, maybe even record video of the entire thing for my review later. And then I want to get feedback from the point of view of these different personas. One user might really want a fast on boarding experience. One user might want advanced customization. We are going to want to take all of that feedback, and make adjustments to get from Alpha to Beta.

With the Alpha group feedback from the prototype, triage, those comments, take the critical and high priority ones, implement them, build through the alpha test level. Check the existing work schedules and sprints for any development items that are marked as post alpha that may need to be implemented prior to beta testing

13 beta test 
Take a look at our alpha group. This is Dur, dreamer, the initial focus group, and the initial engineering group. Take those personas and multiply them times three to get new and varied personas. Vary the ages and demographics and experiences and likes and dislikes. This is our beta group.

Run the application again with playwright or puppeteer or other automatic tool. Again run through every part of the user experience, click every button, enter every text, take screenshots, record videos, get opinions. 

Engineering group against steps in. Again, triage user comments. We should now have a backlog of many comments from the first years a group to now. These should all be in one continuous CSV, notion, or other knowledge base. All critical and high priority items for beta test are ready to go. The system plays the game. Take screenshots. Back to the focus group one last time.

14 release 
At this point, we have run basic ideation between two friends, we did an initial focus group and an initial design. We then went back to the focus group, and went back to the design group, and built the prototype. We enclosed the alpha testing, close, beta, testing, and are ready for a production launch. At this point, assuming we can literally automate the entire process, I would like to see a finished product for the first time. Obviously, this might have some bumps in the road the first few times we run it, but I am hopeful that I cannot only one shot an entire application, but by bringing in actual research and multiple testing stages, we can get an application that not only fully works, but maybe even serves a need in the marketplace.

ALSO look at these for possible
Integration:

https://github.com/AnandChowdhary/continuous-claude

https://github.com/kyegomez/swarms