function [Q, policy, steps] = SarsaLambda(stateSpace, initialStates, ...
    terminalStates, takeAction, initialPolicy, numIterations, gamma, alpha,lambda,epsilon)
% This function implements Sarsa(lambda) algorithm.
% Inputs: stateSapce - matrix with each row representing a state
%         initialStates - matrix containing all possible initial states
%         terminalStates - matrix containing all terminal states
%         takeAction - function that gives S' and reward for the current
%                      state-action pair
%         numIterations - number of total iterations (episodes)
%         gamma - discout factor
%         alpha - learning rate (constant for simplicity)
%         lambda - parameter in Q(lambda)
%         epsilon - parameter in epislon-greedy policy (constant for
%                   simplicity)
% Outputs: Q - matrix containing q-value for each (s,a)
%          policy - matrix containing the probabilities for taking each
%                   action at each state
%          steps - vector, stores number of steps in each episode
%%%%%%%%%%%
% Your code
%%%%%%%%%%%
% initalize policy
policy = initialPolicy;

%initalize action value function
Q = zeros(70,4);

%initalize step counter
steps = zeros(numIterations,1);

for i = 1:numIterations
    terminal = false;
    %trace
    E = zeros(70,4);

    %initalize state
    state = initialStates;
    state_index = find(all(repmat(state,length(stateSpace),1) == stateSpace, 2));

    %Wasn't clear how actions should be initialized so I used epsilon greedy
    %choose action that uses policy derived from Q(epislon-greedy)
    %generate a random probability between 1-0
    probability =rand;

    %if probability below epsilon then pick random action
    if probability <= .1
        action = randi(length(Q(state_index,:)));
    %otherwise pick action that maximizes action value function
    else
        action = (find(Q(state_index,:) == max(Q(state_index,:))));
        if length(action) > 1
            action_index = randi(length(action));
            action = action(action_index);
        end
    end

    % for each step in episode
    while terminal == false
        %increment step counter
        steps(i) = steps(i) + 1;

        %state index
        state_index = find(all(repmat(state,length(stateSpace),1) == stateSpace, 2));

        %take action observe reward and next state
        [next_state, reward] = takeAction(state, action);
        next_state_index = find(all(repmat(next_state,length(stateSpace),1) == stateSpace, 2));

        %choose a' from using policy derived from Q(epislon-greedy)
        %if probability below epsilon then pick random action
        probability =rand;
        if probability <= epsilon
            next_action = randi(length(Q(next_state_index,:)));
        %otherwise pick action that maximizes action value function
        else
            next_action = (find(Q(next_state_index,:) == max(Q(next_state_index,:))));
            if length(next_action) > 1
                next_action_index = randi(length(next_action));
                next_action = next_action(next_action_index);
            end
        end

        % Determine action value function for next state
        next_q = Q(next_state_index, next_action);
        %TD error
        delta = (reward + (gamma)*(next_q) - Q(state_index, action));

        %increment trace
        E(state_index, action) = E(state_index, action) + 1;

        %update q_pi over all s and a
        for s = 1:length(stateSpace)
            for a = 1:length(Q(s,:))
                Q(s, a) = (Q(s, a) + ((alpha)*(delta)*(E(s, a))));
                E(s,a) = (gamma)*(lambda)*(E(s,a));
            end
        end

        %update state and actions
        state = next_state;
        action = next_action;

        %update policy
       for j = 1:length(stateSpace)
            action_set = Q(j,:);
            numerator = (action_set == max(action_set));
            policy(j,:) = numerator/sum(numerator);
       end

        %is state terminal?
        if state == terminalStates
            terminal = true;
        end
    end
end
end
