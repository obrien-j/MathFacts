# MathFacts App Planning - Clarifying Questions

Please answer these questions inline to help define the requirements and ensure we build an app that effectively leverages learning science principles.

## Target Audience & Scope

### Age Range & Grade Level
**What specific age range are you targeting?**
- [ ] 5-7 years (Kindergarten - 1st grade)
- [ ] 6-8 years (1st - 2nd grade)
- [ ] 8-10 years (3rd - 4th grade)
- [ ] Broader range: 6 - 15 years
- [ ] Other: _______________

**Answer:** 
Broader range: 6 - 15 years

**Which grade levels should the app support?**
- [ ] K-2 (focus on basic facts)
- [ ] 3-5 (building fluency)
- [ ] Mixed/adaptive across grades
- [ ] Other: _______________

**Answer:** 
Mixed/adaptive across grades

**Should the app adapt difficulty based on the child's current skill level?**
- [ ] Yes - automatically adjust based on performance
- [ ] Yes - but with manual grade/level selection
- [ ] Mixed/adaptive across grades
- [ ] Other approach: _______________

**Answer:**
Mixed/adaptive across grades 

### Math Operations Priority

**Should we start with addition only and add other operations later?**
- [ ] Yes - addition first, then expand
- [ ] No - include multiple operations from start
- [ ] Other approach: _______________

**Answer:** 
No - include multiple operations from start

**What's the priority order for operations?**
1. addition
2. subtraction
3. multiplication

**Do you want mixed operation practice sessions?**
- [ ] Yes - mix operations within sessions
- [ ] No - separate sessions per operation
- [ ] Both options available
- [ ] Other: _______________

**Answer:** 
Yes - mix operations within sessions, by user choice

## Learning Science Implementation

### Active Retrieval

**Should problems be presented without multiple choice initially (forcing recall)?**
- [ ] Yes - always force recall first
- [ ] Sometimes - depending on difficulty level
- [ ] No - provide options to reduce frustration
- [ ] Other approach: _______________

**Answer:** 
Yes - always force recall first

**How long should we give kids to attempt recall before showing hints?**
- [ ] 3-5 seconds
- [ ] 5-10 seconds
- [ ] 10-15 seconds
- [ ] Adjustable based on child's pace
- [ ] Other: _______________

**Answer:** 
5-10 seconds

**Should we track response time as a fluency indicator?**
- [ ] Yes - speed is crucial for automaticity
- [ ] Yes - but don't stress kids about it
- [ ] No - accuracy is more important
- [ ] Track but don't show to kids

**Answer:** 
Yes - but don't stress kids about it

### Spaced Repetition

**How frequently should mastered facts be reviewed?**
- [ ] Daily
- [ ] Every 2-3 days
- [ ] Weekly
- [ ] Algorithm-determined optimal intervals
- [ ] Other: _______________

**Answer:** 
Algorithm-determined optimal intervals

**Should we use a sophisticated algorithm (like SM-2) or simpler spaced repetition?**
- [ ] Advanced algorithm for optimal retention
- [ ] Simple system (easier to implement)
- [ ] Start simple, upgrade later
- [ ] Other approach: _______________

**Answer:** 
Simple system (easier to implement)

**How do we define "mastered"?**
- [ ] 3 consecutive correct answers
- [ ] 5 consecutive correct answers
- [ ] Correct + under time threshold (e.g., 3 seconds)
- [ ] Combination: _____ correct answers under _____ seconds
- [ ] Other criteria: _______________

**Answer:** 
Correct + under time threshold (e.g., 3 seconds)

### Interleaving

**Should we mix different operation types within a session?**
- [ ] Yes - helps with discrimination
- [ ] No - focus on one operation at a time
- [ ] Optional - let users choose
- [ ] Depends on skill level

**Answer:** 
Optional - let users choose

**Should we mix difficulty levels within sessions?**
- [ ] Yes - mix easy and hard problems
- [ ] No - gradual progression
- [ ] Optional setting
- [ ] Other approach: _______________

**Answer:** 
Yes - mix easy and hard problems

**How much variety vs. focused practice do you prefer?**
- [ ] High variety - keeps kids engaged
- [ ] Moderate variety - some mixing
- [ ] Low variety - focused practice
- [ ] Adaptive based on performance

**Answer:** 
Moderate variety - some mixing

### Test Effect

**Should we include formal "test" modes separate from practice?**
- [ ] Yes - regular assessments
- [ ] No - all practice-based
- [ ] Optional feature
- [ ] Other approach: _______________

**Answer:** 
Yes - regular assessments

**How often should we assess overall progress?**
- [ ] Daily mini-assessments
- [ ] Weekly progress checks
- [ ] Monthly comprehensive tests
- [ ] User-initiated when ready
- [ ] Other: _______________

**Answer:** 
Weekly progress checks

**Should kids see their improvement over time through charts/graphs?**
- [ ] Yes - motivating to see progress
- [ ] Yes - but simple visualizations
- [ ] No - might create pressure
- [ ] Optional setting for parents to enable

**Answer:** 
Yes - but simple visualizations

## User Experience & Motivation

### Progress Tracking

**Do you want visual progress indicators?**
- [ ] Progress bars for each operation
- [ ] Badge/achievement system
- [ ] Certificates for milestones
- [ ] Simple star ratings
- [ ] All of the above
- [ ] None - keep it simple
- [ ] Other: _______________

**Answer:** 
Progress bars for each operation

**Should parents/teachers have access to progress reports?**
- [ ] Yes - detailed analytics
- [ ] Yes - simple summaries
- [ ] Optional - child can share
- [ ] No - child's private progress

**Answer:** 
Optional - child can share

**How granular should progress tracking be?**
- [ ] Individual fact level (e.g., 7+8 mastery)
- [ ] Operation level (addition progress)
- [ ] Overall fluency score
- [ ] All levels with drill-down capability
- [ ] Other: _______________

**Answer:** 
Overall fluency score

### Gamification

**Any specific themes or characters kids might enjoy?**
- [ ] Space/astronaut theme
- [ ] Animal characters
- [ ] Fantasy/adventure
- [ ] Sports theme
- [ ] Simple/minimal design
- [ ] Let me suggest: _______________

**Answer:** 
Simple/minimal design

**Should we include mini-games or stick to straightforward fact practice?**
- [ ] Mini-games to break up practice
- [ ] Straightforward practice only
- [ ] Both - games as rewards
- [ ] Other approach: _______________

**Answer:** 
Straightforward practice only

**Preferred rewards system:**
- [ ] Points and leaderboards
- [ ] Stars and achievements
- [ ] Unlockable content/characters
- [ ] Simple positive feedback
- [ ] No rewards - intrinsic motivation
- [ ] Other: _______________

**Answer:** 
Simple positive feedback

### Session Structure

**How long should typical practice sessions be?**
- [ ] 3-5 minutes (very short)
- [ ] 5-10 minutes (short)
- [ ] 10-15 minutes (medium)
- [ ] Flexible - user controlled
- [ ] Adaptive based on attention span

**Answer:** 
5-10 minutes (short)

**Should the app suggest when to practice based on spaced repetition timing?**
- [ ] Yes - push notifications
- [ ] Yes - in-app suggestions only
- [ ] No - user decides when
- [ ] Optional setting

**Answer:** 
Yes - push notifications

**Daily goals or streaks to encourage regular practice?**
- [ ] Daily practice streaks
- [ ] Weekly goals
- [ ] Flexible goals set by parent/child
- [ ] No goals - avoid pressure
- [ ] Other: _______________

**Answer:** 
Daily practice streaks

## Technical Considerations

### Offline Capability

**Should the app work offline once downloaded?**
- [ ] Yes - completely offline capable
- [ ] Mostly offline with optional cloud sync
- [ ] Online required for progress tracking
- [ ] Other: _______________

**Answer:** 
Yes - completely offline capable

**Cloud sync for progress across devices?**
- [ ] Yes - seamless across devices
- [ ] Optional feature
- [ ] No - single device use
- [ ] Other: _______________

**Answer:** 
Optional feature

### Accessibility

**Any specific accessibility requirements?**
- [ ] Screen reader support
- [ ] Large text options
- [ ] High contrast mode
- [ ] Audio instructions/feedback
- [ ] Motor accessibility (larger buttons)
- [ ] All of the above
- [ ] Other: _______________

**Answer:** 
None to start

**Support for different learning styles:**
- [ ] Visual (number representations)
- [ ] Auditory (spoken problems)
- [ ] Kinesthetic (touch interactions)
- [ ] All modalities
- [ ] Other: _______________

**Answer:** 
None to start

### Data & Privacy

**Will this be used in schools, homes, or both?**
- [ ] Primarily home use
- [ ] Primarily school use
- [ ] Both - needs classroom features
- [ ] Both - but separate versions

**Answer:** 
Primarily home use

**Any specific privacy requirements for children's data?**
- [ ] COPPA compliance required
- [ ] FERPA compliance for schools
- [ ] Minimal data collection
- [ ] Local storage only
- [ ] Other requirements: _______________

**Answer:** 
None

## Initial Feature Scope (MVP)

### Minimum Viable Product Priority

**What should be included in the first version?**
- [ ] Single operation (addition 0-10)
- [ ] Two operations (addition + subtraction)
- [ ] All three operations
- [ ] Other scope: _______________

**Answer:** 
Single operation (addition 0-10)

**Most important learning science principle to get right first:**
- [ ] Active retrieval (no hints initially)
- [ ] Spaced repetition (smart review timing)
- [ ] Interleaving (mixed practice)
- [ ] Test effect (regular assessment)
- [ ] All equally important

**Answer:** 
Active retrieval (no hints initially)

**Essential features for MVP:**
- [ ] Basic fact practice
- [ ] Progress tracking
- [ ] Spaced repetition
- [ ] Simple rewards/motivation
- [ ] Parent dashboard
- [ ] Other: _______________

**Answer:** 
Basic fact practice

## Additional Requirements

**Anything else important that wasn't covered above?**

**Answer:** 
Optional hint/cheat code capability that shows optimal math strategies for breaking apart complex problems (e.g., decomposition, doubles, near-doubles, make-ten strategies). This should be available after the initial retrieval attempt (around 8 seconds) to maintain active retrieval benefits while providing learning support. 

---

## Next Steps
Once you've filled this out, we'll use your answers to create:
1. Technical specification document
2. User experience flow diagrams
3. Development roadmap with phases
4. Learning science implementation details