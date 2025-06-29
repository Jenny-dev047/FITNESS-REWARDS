# FITNESS-REWARDS

A blockchain-based fitness and wellness platform that incentivizes healthy behaviors through verifiable activity tracking and token-based rewards.

## Overview

FITNESS-REWARDS gamifies health and fitness by providing transparent, verifiable rewards for achieving fitness goals, participating in challenges, and maintaining healthy lifestyles.

## Features

- **Activity Tracking**: Comprehensive logging of fitness activities and health metrics
- **Goal Setting**: Personal fitness goals with customizable targets and rewards
- **Token Rewards**: Earn tokens for achieving fitness milestones and goals
- **Fitness Challenges**: Community competitions with prize pools
- **Trainer Network**: Connect with verified fitness professionals
- **Progress Monitoring**: Track health improvements over time

## Contract Functions

### Public Functions

- `create-user-profile(name, age, fitness-level, goals)` - Create fitness profile
- `register-trainer(name, certification, specialization, rate)` - Register as fitness trainer
- `verify-trainer(trainer)` - Admin function to verify trainer credentials
- `set-fitness-goal(goal-type, target-value, deadline, reward-amount)` - Set personal fitness goal
- `log-activity(date, steps, calories, workout-minutes, heart-rate)` - Log daily fitness activity
- `verify-activity(user, date)` - Admin function to verify activity data
- `update-goal-progress(goal-id, new-value)` - Update progress toward fitness goal
- `create-challenge(name, description, challenge-type, target, duration, prize-pool, max-participants)` - Create fitness challenge
- `join-challenge(challenge-id)` - Join community fitness challenge
- `update-challenge-progress(challenge-id, progress)` - Update challenge participation progress
- `claim-rewards(goal-id)` - Claim tokens for completed verified goals
- `fund-reward-pool(amount)` - Admin function to add tokens to reward pool

### Read-Only Functions

- `get-user-profile(user)` - Get user fitness profile and statistics
- `get-fitness-goal(goal-id)` - Get fitness goal details and progress
- `get-fitness-challenge(challenge-id)` - Get challenge information and status
- `get-challenge-participation(challenge-id, user)` - Get user's challenge participation
- `get-activity-log(user, date)` - Get daily activity data
- `get-trainer-info(trainer)` - Get fitness trainer profile

## Usage

### For Users
1. Create profile with `create-user-profile`
2. Set fitness goals using `set-fitness-goal`
3. Log daily activities with `log-activity`
4. Update goal progress as you achieve milestones
5. Join community challenges for extra motivation
6. Claim token rewards for completed goals

### For Trainers
1. Register with credentials using `register-trainer`
2. Wait for admin verification
3. Offer services to platform users
4. Help users achieve their fitness goals
5. Build reputation through user success

### For Challenges
1. Browse active community challenges
2. Join challenges that match your fitness level
3. Track progress throughout challenge duration
4. Compete for prize pool rewards
5. Build community connections and motivation

## Reward System

- **Goal Completion**: Earn tokens for achieving personal fitness goals
- **Challenge Prizes**: Win from community challenge prize pools
- **Consistency Bonuses**: Extra rewards for maintaining regular activity
- **Milestone Rewards**: Special bonuses for major achievements
- **Verification Required**: All rewards require activity verification

## Health Metrics

- **Step Tracking**: Daily step count monitoring
- **Calorie Burn**: Exercise and activity calorie tracking
- **Workout Duration**: Time spent in active exercise
- **Heart Rate**: Average heart rate monitoring
- **Progress Trends**: Long-term health improvement tracking

## Community Features

- **Fitness Challenges**: Group competitions and events
- **Leaderboards**: Community rankings and achievements
- **Trainer Network**: Access to certified fitness professionals
- **Goal Sharing**: Community support and accountability
- **Achievement Recognition**: Public celebration of milestones

## Verification & Security

- **Activity Verification**: Admin verification of logged activities
- **Trainer Certification**: Verified fitness professional credentials
- **Goal Validation**: Confirmed achievement of fitness targets
- **Reward Protection**: Secure token distribution system
- **Data Integrity**: Immutable fitness and health records
