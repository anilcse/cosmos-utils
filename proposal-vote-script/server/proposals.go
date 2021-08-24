package server

import (
	"encoding/json"
	"log"
	"net/http"
	"os/exec"

	"github.com/vitwit/cosmos-utils/proposal-vote-script/config"
)

// VoteProposals is to vote for the proposals which are in voting period
func VoteProposals(cfg *config.Config) error {
	var validatorVoted string

	ops := HTTPOptions{
		Endpoint: cfg.LCDEndpoint + "/cosmos/gov/v1beta1/proposals?proposal_status=2",
		Method:   http.MethodGet,
	}

	resp, err := HitHTTPTarget(ops)
	if err != nil {
		log.Printf("Error while getting voting period proposals: %v", err)
		return err
	}

	var p Proposals
	err = json.Unmarshal(resp.Body, &p)
	if err != nil {
		log.Printf("Error while unmarshelling vote proposal response: %v", err)
		return err
	}

	log.Printf("Length of voting proposals : %v", len(p.Proposals))

	if p.Proposals == nil {
		log.Println("No voting period proposals")
	}

	for _, proposal := range p.Proposals {
		// if proposal.Status == "PROPOSAL_STATUS_VOTING_PERIOD" {
		log.Printf("Voting period proposal ID : %v", proposal.ProposalID)

		ops = HTTPOptions{
			Endpoint: cfg.LCDEndpoint + "/cosmos/gov/v1beta1/proposals/" + proposal.ProposalID + "/votes",
			Method:   http.MethodGet,
		}

		resp, err := HitHTTPTarget(ops)
		if err != nil {
			log.Printf("Error while getting voting period proposals: %v", err)
			return err
		}

		var v ProposalVoters
		err = json.Unmarshal(resp.Body, &v)
		if err != nil {
			log.Printf("Error while unmarshelling proposal votes response: %v", err)
			return err
		}

		for _, value := range v.Votes {
			if value.Voter == cfg.AccountAddress {
				validatorVoted = value.Option
				break
			}
		}

		log.Printf("Vote Option : %v for proposal ID : %v", validatorVoted, proposal.ProposalID)

		if validatorVoted == "VOTE_OPTION_NO" || validatorVoted == "" {
			cmd := exec.Command(cfg.Deamon, "tx", "gov", "vote", proposal.ProposalID, "yes", "--from", cfg.KeyName, "--chain-id", cfg.ChainID, "--keyring-backend", "test", "--fees", cfg.Fees, "-y")
			log.Printf("Vote command : %v", cmd)
			out, err := cmd.CombinedOutput()
			if err != nil {
				log.Printf("Error while running vote tx : %v : %v", err, cmd)
				return err
			}

			log.Printf("Output : %v ", string(out))
		}
		// }
	}
	return nil
}
