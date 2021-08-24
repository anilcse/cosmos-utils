package server

type (
	// QueryParams to map the query params of an url
	QueryParams map[string]string

	// HTTPOptions of a target
	HTTPOptions struct {
		Endpoint    string
		QueryParams QueryParams
		Body        []byte
		Method      string
	}

	// PingResp struct
	PingResp struct {
		StatusCode int
		Body       []byte
	}

	// ProposalResultContent struct holds the parameters of a proposal content result
	ProposalResultContent struct {
		Type  string `json:"type"`
		Value struct {
			Title       string `json:"title"`
			Description string `json:"description"`
		} `json:"value"`
	}

	// ProposalResult struct holds the parameters of proposal result
	ProposalResult struct {
		Content          ProposalResultContent `json:"content"`
		ID               string                `json:"id"`
		ProposalStatus   string                `json:"proposal_status"`
		FinalTallyResult interface{}           `json:"final_tally_result"`
		SubmitTime       string                `json:"submit_time"`
		DepositEndTime   string                `json:"deposit_end_time"`
		TotalDeposit     []interface{}         `json:"total_deposit"`
		VotingStartTime  string                `json:"voting_start_time"`
		VotingEndTime    string                `json:"voting_end_time"`
	}

	// Proposals struct holds result of array of proposals
	Proposals struct {
		Proposals []struct {
			ProposalID string `json:"proposal_id"`
			Content    struct {
				Type        string `json:"@type"`
				Title       string `json:"title"`
				Description string `json:"description"`
				Changes     []struct {
					Subspace string `json:"subspace"`
					Key      string `json:"key"`
					Value    string `json:"value"`
				} `json:"changes"`
			} `json:"content,omitempty"`
			Status           string `json:"status"`
			FinalTallyResult struct {
				Yes        string `json:"yes"`
				Abstain    string `json:"abstain"`
				No         string `json:"no"`
				NoWithVeto string `json:"no_with_veto"`
			} `json:"final_tally_result"`
			SubmitTime     string `json:"submit_time"`
			DepositEndTime string `json:"deposit_end_time"`
			TotalDeposit   []struct {
				Denom  string `json:"denom"`
				Amount string `json:"amount"`
			} `json:"total_deposit"`
			VotingStartTime string `json:"voting_start_time"`
			VotingEndTime   string `json:"voting_end_time"`
		} `json:"proposals"`
		Pagination interface{} `json:"pagination"`
	}

	// ProposalVoters struct holds the parameters of proposal voters
	ProposalVoters struct {
		Vote struct {
			ProposalID string `json:"proposal_id"`
			Voter      string `json:"voter"`
			Option     string `json:"option"`
		} `json:"vote"`
	}
)
