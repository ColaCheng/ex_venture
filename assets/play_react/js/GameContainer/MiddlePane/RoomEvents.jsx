import React, { Component } from 'react';
import { connect } from 'react-redux';
import styled, { css } from 'styled-components';

// const RoomEvents = ({ className, eventStream }) => {
//   return (
//     <div className={className}>
//       RoomEvents
//       <div>
//         {eventStream.map(event => {
//           return (
//             <div>
//               <div>{event}</div>
//               <br />
//             </div>
//           );
//         })}
//         <div
//           ref={el => {
//             this.messagseEnd = el;
//           }}
//         />
//       </div>
//     </div>
//   );
// };

class RoomEvents extends Component {
  constructor(props) {
    super(props);
    this.scrollToBottom = this.scrollToBottom.bind(this);
  }
  scrollToBottom() {
    this.messagesEnd.scrollIntoView({ behavior: 'smooth' });
  }

  componentDidMount() {
    this.scrollToBottom();
  }

  componentDidUpdate() {
    this.scrollToBottom();
  }
  render() {
    return (
      <div className={this.props.className}>
        RoomEvents
        <div>
          {this.props.eventStream.map(event => {
            return (
              <div key={event.sent_at}>
                <div>{event.message}</div>
                <br />
              </div>
            );
          })}
          <div
            ref={el => {
              this.messagesEnd = el;
            }}
          />
        </div>
      </div>
    );
  }
}

RoomEvents.defaultProps = {
  eventStream: []
};

const mapStateToProps = state => {
  return { eventStream: state.eventStream };
};

export default connect(mapStateToProps)(styled(RoomEvents)`
  height: 100%;
  overflow: scroll;
`);
